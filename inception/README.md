# Inception openshift deployment steps

### Motivation
This document is a description of the process for adding a new service to an OpenShift cluster.  It covers service-level configuration, containerization, and authentication through a reverse-proxy.  These are not exactly operational tasks for the cluster, but many of the steps are performed with "oc" commands and so are done by someone with authority to alter deployments in the cluster.
I hope it will be useful for someone performing service administration while new to Openshift.

### Prerequisites

- Github account
- Quay.io account with cli password set
- Permission to access clusters cl1, cl2
- developers.redhat.com account (optional, has useful documentation)


### Install openshift command line tool
https://docs.okd.io/latest/cli_reference/openshift_cli/getting-started-cli.html

https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/

The standard openshift tool is not freely available, so use the upstream, open-source tool.


### Log in to cluster1
Before logging in, oc status says this:


`$ oc status
error: You must be logged in to the server (Unauthorized)`

Actually, the very first time you type ask for “oc status” it will say that you are missing configuration.  That will be populated by logging in the first time.


Use a browser to get the login url from here:

https://console-openshift-console.apps.odh-cl1.apps.os-climate.org/k8s/ns/inception

When prompted, select to log in with githubidp


After logging in you will need to navigate to the inception namespace or project:


`oc project inception`


In the upper right corner, there is a drop down menu with “copy login command”

Use that to display token and get the login command for oc


After authentication, oc status says this:


```$ oc status

In project INCEpTION (inception) on server https://api.odh-cl1.apps.os-climate.org:6443


http://inception-inception.apps.odh-cl1.apps.os-climate.org to pod port 8080-tcp (svc/inception)

  deployment/inception deploys istag/inception:latest

    deployment #2 running for 7 days - 1 pod

    deployment #1 deployed 7 days ago



1 info identified, use 'oc status --suggest' to see details.
```

Locate the project page for the application
https://inception-project.github.io/

The download page offers a jar file.  That works, but it would be nicer to have a container.

Searching dockerhub turns this up:

https://hub.docker.com/r/inceptionproject/inception


### Try out the container locally with podman

`podman pull inceptionproject/inception`


### Use this containerfile to build a container:

```
FROM docker.io/inceptionproject/inception


LABEL name="inception-app" \

      vendor="rdaylf" \

      summary="inception image" \

      description="An inception image configured for pre-authentication."


EXPOSE 8080
```

### Build a base image based on that containerfile

`podman build -t=inception .`

`podman run -d -p 8080:8080 inceptionproject/inception`


Check the version:


```podman exec -it competent_babbage bash

root@aa911693b57c:/opt/inception# cat /export/version 

25.2
```
These are the steps that will have to be repeated when it is time to deploy a newer version of inception.

### Stop the container, commit, and push to quay.

`podman commit aa911693b57c quay.io/rdaylf/inception`

`podman push quay.io/rdaylf/inception`


This image is now ready to be consumed by an openshift deployment.  Our configuration will be mounted on to /export in the container and will come from an openshift secret.

### Create the app

```oc new-app inceptionproject/inception

--> Found container image b62e921 (8 days old) from Docker Hub for "inceptionproject/inception"


    * An image stream tag will be created as "inception:latest" that will track this image


--> Creating resources ...

    imagestream.image.openshift.io "inception" created

    deployment.apps "inception" created

    service "inception" created

--> Success

    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:

'oc expose service/inception'

Run 'oc status' to view your app.
```
### Issue the command to create a network route to the application
```
oc expose service/inception
route.route.openshift.io/inception exposed
```

### Login to the application

http://inception-inception.apps.odh-cl1.apps.os-climate.org/


Immediately change the password from the default and store in 1password.

### Get the deployment.yaml
`oc get deployment inception -o yaml > inception-deployment.yaml`


### Deploy with this command

`oc create -f inception-deployment.yaml`



### Hook up client side authentication to dex

It would be ideal if inception supported openidc external authentication, but it does not.


There is a ticket open with inception for this feature:

https://github.com/inception-project/inception/issues/2741


Absent direct openidc authentication inside inception, it is possible to set up apache as a reverse proxy with mod_auth_openidc.


Here is a user-submitted config for this:

https://github.com/inception-project/inception/pull/2800#issuecomment-1005196261


### Work locally with podman to develop an apache reverse proxy
Start with a Redhat universal base image and add apache and proxy config.

`podman run -dit --name inception-proxy -p 8081:80 httpd:2.4`


Enable proxy modules and set up virtualhost to proxy for inception

This apache virtualhost works to redirect to an inception container running locally in my lab:


 
```
<VirtualHost *:80>

  ServerName inception.finninday.net

  ProxyPass        / http://10.0.0.10:8080/login.html

  ProxyPassReverse / http://10.0.0.10:8080/login.html


  OIDCProviderMetadataURL https://dex-humair-sandbox.apps.odh-cl2.apps.os-climate.org/.well-known/openid-configuration

  OIDCRedirectURI http://web-3.finninday.net/protected

  OIDCCryptoPassphrase different-secret

  OIDCClientSecret some-secret

  OIDCClientID inception

  OIDCRemoteUserClaim email

  OIDCAuthNHeader remote_user


<Location />

  AuthType openid-connect

  Require valid-user

  LogLevel debug

</Location>

</VirtualHost>
```


### Test authentication against a dex sandbox instance.


Based on this config, connections to the proxy are authenticated by Humair’s sandbox, almost. I still have to register my OIDCRedirectURI with dex.  That happens in this configmap:

https://console-openshift-console.apps.odh-cl2.apps.os-climate.org/k8s/ns/humair-sandbox/configmaps/dex

I’ve added my URI (http://web-3.finninday.net/protected)  to the list for staticClients.

Delete the pod to get a new pod that will read the new configmap.


After a successful authentication with dex, I’m redirected back to the proxy and I get this error:

Error:


OpenID Connect Provider error: Remote user could not be set: contact the website administrator

I have to figure out how to proceed past the authentication.  I’ll need to tell inception who the authenticated user is somehow.


After updating my proxy redirect uri to a valid location within the inception app, I now have a clean session handoff to inception.  Images display properly and links work.  

Successful logs from the apache module auth_openidc look like this:

```
Wed Sep 07 17:51:03.273183 2022] [auth_openidc:debug] [pid 19803] src/util.c(1284): [client 10.0.0.10:52268] oidc_util_set_app_info: setting environment variable "OIDC_access_token_expires: 1663177844"

[Wed Sep 07 17:51:03.273188 2022] [authz_core:debug] [pid 19803] mod_authz_core.c(809): [client 10.0.0.10:52268] AH01626: authorization result of Require valid-user : granted

[Wed Sep 07 17:51:03.273191 2022] [authz_core:debug] [pid 19803] mod_authz_core.c(809): [client 10.0.0.10:52268] AH01626: authorization result of <RequireAny>: granted

[Wed Sep 07 17:51:03.273202 2022] [auth_openidc:debug] [pid 19803] src/config.c(1824): [client 10.0.0.10:52268] oidc_auth_fixups: overlaying env with 10 elements
```

But the app doesn’t honor the pre-authentication and is prompting for another login.

### Generate inception configuration to assume pre-authentication by reverse proxy
So far, we have configured a reverse proxy to redirect to dex for authentication, but inception needs to accept pre-authentication and deal properly with the authenticated user.


This is the model config that I pulled from another inception user who is using this method of external authentication:

```
server.use-forward-headers=true
wicket.core.csrf.enabled=false
wicket.core.csrf.no-origin-action=allow
remote-api.enabled=true
annotation.default-preferences.page-size=2000
auth.mode                     = preauth
auth.preauth.header.principal = remote_user
auth.preauth.newuser.roles    = ROLE_PROJECT_CREATOR
```

To troubleshoot and verify the operation of inception pre-authentication, it would be ideal to view the headers and cookies presented before and after authentication.  However, the mod_auth_openidc module purposely strips headers that could leak secrets, so troubleshooting must rely on the debug logs for the apache module.


Documentation about Inception header-based pre-authentication: (https://inception-project.github.io/releases/21.5/docs/admin-guide.html#sect_security_preauth), 


This cookie is a clue that authentication has been successful.

`Cookie: mod_auth_openidc_session=73a19120-7525-45e9-8189-cf0c6be27160; JSESSIONID=4E7B75C60A07A3E06629D82194C95185`


Set the module configuration to send username along after authentication so that inception can recognize that pre-authentication has been successful.

```
  OIDCRemoteUserClaim email
  OIDCAuthNHeader remote_user
```

But with that configuration, even after authentication, the remote_user is not getting set.  Apache error logs from the module say this:

```
[Wed Sep 07 23:16:13.440057 2022] [auth_openidc:error] [pid 20058] [client 10.0.0.10:57670] oidc_get_remote_user: OIDCRemoteUserClaim is set to "email", but the id_token JSON payload did not contain a "email" string
```

The id_token JSON string that it refers to is included in the Apache module logs, dumping the JWT (Java web token) data structure.  And it is true, that there is no slot for the email or any of the other claims that I try.  “Sub” is a special, default claim that is a random token, but is not meant for display to humans.

Googling for the error, I find that there is bug in Apache module mod_auth_openidc that generates the symptoms that I’m seeing:

https://github.com/zmartzone/mod_auth_openidc/issues/360

On closer inspection of the log message it seems like you're using an old version of mod_auth_openidc, namely <= 1.8.9. This issue was addressed in 1.8.10 and beyond and the log message has changed since then.


See the release notes of 1.8.10 https://github.com/zmartzone/mod_auth_openidc/releases/tag/v1.8.10 and #145 of June 2016.


The dex config (https://dex-humair-sandbox.apps.odh-cl2.apps.os-climate.org/.well-known/openid-configuration) shows that these claims should work:
```
 "claims_supported": [
    "iss",
    "sub",
    "aud",
    "iat",
    "exp",
    "email",
    "email_verified",
    "locale",
    "name",
    "preferred_username",
    "at_hash"
  ]
```

I’ve been using the latest version of the Apache module for CentOS7 which is currently mod_auth_openidc-1.8.8-9.el7_9.x86_64.  There is a newer version available here:

https://github.com/zmartzone/mod_auth_openidc/releases/download/v2.4.11.3/mod_auth_openidc-2.4.11.3-1.el7.x86_64.rpm

### Install it and the cjose dependency.

Now I’m at mod_auth_openidc-2.4.11.3-1.el7.x86_64

There must also be a configuration change to use more claims than just sub:

 `OIDCScope "openid email profile"`

With that in place, and the newer version of mod_auth_openidc, I see the id_token with my github username populated.

These claims all seem to be possible options for setting remote_user:
```
"email":"rynofinn",
"email_verified":false,
"name":"rynofinn",
"preferred_username":"rynofinn"}
```

Importantly, this now appears in the apache reverse proxy logs:

```
[Thu Sep 08 18:55:25.430959 2022] [auth_openidc:debug] [pid 1228] src/mod_auth_openidc.c(1679): [client 10.0.0.10:55250] oidc_set_request_user: set remote_user to "rynofinn" based on claim: "name"
```

So remote_user is set, and yet it still ends up eventually redirecting to here:
```
[Thu Sep 08 18:55:25.624887 2022] [authz_core:debug] [pid 1228] mod_authz_core.c(809): [client 10.0.0.10:55250] AH01626: authorization result of Require valid-user : granted, referer: http://web-3.finninday.net/login.html
```

This inception configuration is in /export/settings.properties results in successful pre-authentication:
```
server.use-forward-headers=true
wicket.core.csrf.enabled=false
wicket.core.csrf.no-origin-action=allow
remote-api.enabled=true
annotation.default-preferences.page-size=2000
login.message = <span style="color:red;font-size: 200%;">finninday.net</span>
useSSL=false
allowPublicKeyRetrieval=true
serverTimezone=UTC
server.tomcat.internal-proxies=127\.0\.[0-1]\.1
server.tomcat.remote-ip-header=x-forwarded-for
server.tomcat.accesslog.request-attributes-enabled=true
server.tomcat.protocol-header=x-forwarded-proto
server.tomcat.protocol-header-https-value=https
server.use-forward-headers=true
wicket.core.csrf.enabled=false
wicket.core.csrf.no-origin-action=allow
remote-api.enabled=true
annotation.default-preferences.page-size=2000
auth.mode                     = preauth
auth.preauth.header.principal = remote_user
auth.preauth.newuser.roles    = ROLE_PROJECT_CREATOR
```

That configuration snippet which allows extra headers to be passed between the proxy and the application was found here:

https://github.com/inception-project/inception/pull/2800#issuecomment-1005196261

Let it be noted that this user complained that the pre-authentication configuration was not well documented and suggested that this config be added to the docs.

Build an image for reverse proxy and store on quay
Start with ubi8 and then enable centos8 streams to install the needed packages for Apache and the openidc Apache authentication module.


Use this Containerfile to achieve the proper build:

```
FROM registry.access.redhat.com/ubi8/ubi-init:latest

ARG ARCH=x86_64
ARG DBUS_API_REF=master

LABEL name="inception-proxy" \
      vendor="rdaylf" \
      summary="httpd image with external authentication" \
      description="An httpd image which includes packages and configuration necessary for handling external authentication."

RUN dnf -y --disableplugin=subscription-manager --setopt=tsflags=nodocs install \
      http://mirror.centos.org/centos/8-stream/BaseOS/${ARCH}/os/Packages/centos-stream-repos-8-2.el8.noarch.rpm \
      http://mirror.centos.org/centos/8-stream/BaseOS/${ARCH}/os/Packages/centos-gpg-keys-8-2.el8.noarch.rpm && \
    dnf -y --disableplugin=subscription-manager module enable mod_auth_openidc && \
    dnf -y --disableplugin=subscription-manager --setopt=tsflags=nodocs install \
      httpd \
      mod_ssl \

      # SSSD Packages \
      sssd \
      sssd-dbus \
      # Apache External Authentication Module Packages \
      mod_auth_gssapi \
      mod_authnz_pam \
      mod_intercept_form_submit \
      mod_lookup_identity \
      mod_auth_mellon \
      mod_auth_openidc

## Remove any existing configurations

RUN rm -f /etc/httpd/conf.d/*

## Create the mount point for the authentication configuration files

RUN mkdir /etc/httpd/auth-conf.d

# place the virtualhost config for reverse proxy to inception

COPY container-assets/inception-proxy.conf /etc/httpd/conf.d/inception-proxy.conf

# set the listen port to 8081

COPY container-assets/httpd.conf /etc/httpd/conf/httpd.conf

## Make sure httpd has the environment variables needed for external auth

RUN  mkdir -p /etc/systemd/system/httpd.service.d

EXPOSE 8081

WORKDIR /etc/httpd

RUN systemctl enable httpd

CMD [ "/sbin/init" ]
```

That Containerfile references two Apache config files to set the VirtualHost and Listen port.

Inception-proxy.conf:
```
<VirtualHost *:8081>

  ServerName inception.finninday.net

  OIDCProviderMetadataURL https://dex-humair-sandbox.apps.odh-cl2.apps.os-climate.org/.well-known/openid-configuration
  OIDCRedirectURI http://web-3.finninday.net/protected
  OIDCCryptoPassphrase different-secret
  OIDCClientSecret some-secret
  OIDCClientID inception
  OIDCRemoteUserClaim name
  OIDCAuthNHeader remote_user
  OIDCScope "openid email profile"

<Location />
  AuthType openid-connect
  Require valid-user
  LogLevel debug
  ProxyPreserveHost on
  ProxyPass        http://10.0.0.10:8080/
  ProxyPassReverse http://10.0.0.10:8080/
</Location>

</VirtualHost>
```

The httpd.conf that is copied in is the default configuration, but with the Listen port changed from 80 to 8081 to allow a rootless container to attach to the port.


### Store this as an image on quay

```
podman commit a70f301d33a5 quay.io/rdaylf/inception-proxy

podman push quay.io/rdaylf/inception-proxy
```

### Place proxy config into the container via secret mount
Inception-proxy.conf is a snippet of apache config that will get mounted into the container.

Here is a link to the documentation for finding the url that leads to the upstream service for the reverse proxy:

https://stackoverflow.com/questions/59558303/how-to-find-the-url-of-a-service-in-kubernetes

```
<service-name>.<namespace>.svc.cluster.local:<service-port>
<service-name>.<namespace>.svc.cluster.local:<service-port>

<VirtualHost *:8080>
  ServerName inception-proxy.inception.svc.cluster.local
<secrets snipped>
<Location />

  AuthType openid-connect
  Require valid-user
  LogLevel debug
  ProxyPreserveHost on
  ProxyPass        http://inception.inception.svc.cluster.local:8080/
  ProxyPassReverse http://inception.inception.svc.cluster.local:8080/
</Location>

</VirtualHost>
```

### Create the kubernetes secret for proxy config
The secret must exist before the pod that depends upon it can be deployed successfully.

Create the secret from the command line like this:

`oc create -f <filename>`

Or from the web UI.


### Create the kubernetes secret for inception settings.config

Place Inception config into the container via secret mount
The containerized Inception looks for config in /export/settings.properties within the container.  The /export directory is also where the sqlite database is kept.  Even when an external database is configured, the application wants to be able to write logs to /export/logs and we want to place configure in /export/settings.properties.  To allow this to be possible, we can create a volume mount on /export/settings.properties and an empty directory volume mount on /export.


This seems dumb, but it allows the configuration file to be placed which has the side-effect of making the /export directory unwriteable by the application.  The empty volume mount on /export puts an overlay in place that is writable by the application.


A working settings.properties is included below.

```
Settings.properties:
server.use-forward-headers=true
wicket.core.csrf.enabled=false
wicket.core.csrf.no-origin-action=allow
remote-api.enabled=true
annotation.default-preferences.page-size=2000
login.message = <span style="color:red;font-size: 200%;">OS Climate</span>

# Running behind a reverse proxy

server.forward-headers-strategy=NATIVE

database.url=jdbc:mariadb://mariadb.inception.svc.cluster.local:3306/inceptiondb?useSSL=false&serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8
database.username=somename
database.password=somepassword

# 60 * 60 * 24 * 30 = 30 days
#backup.keep.time=2592000
# 60 * 5 = 5 minutes
#backup.interval=300
#backup.keep.number=10

useSSL=false
allowPublicKeyRetrieval=true
serverTimezone=UTC
#server.port=18080
#server.use-forward-headers=true
server.tomcat.internal-proxies=127\.0\.[0-1]\.1
server.tomcat.remote-ip-header=x-forwarded-for
server.tomcat.accesslog.request-attributes-enabled=true
server.tomcat.protocol-header=x-forwarded-proto
server.tomcat.protocol-header-https-value=https
server.use-forward-headers=true
wicket.core.csrf.enabled=false
wicket.core.csrf.no-origin-action=allow
remote-api.enabled=true
annotation.default-preferences.page-size=2000
auth.mode                     = preauth
auth.preauth.header.principal = remote_user
auth.preauth.newuser.roles    = ROLE_PROJECT_CREATOR
```


### Set up a non-toy database for use by inception via template
Inception ships with a sqlite database, but recommends a more robust database for production use.

There is a developer template for deploying a mariadb database.  Initial deployment of the mariadb is done via the developer template.

### Configure server-side for inception authentication
Dex is used to provide openidc authentication.  The calling URI must be registered in dex.

The proxy must accept the headers and tokens after a successful authentication.  The inception application must honor the pre-authenticated session by the headers presented.


### Fork and checkout the apps repo
Starting from the operate first apps repo:

https://github.com/operate-first/apps.git

Create a fork and populate it with deployment configuration for the inception application

```
$ git remote -v
origin  git@github.com:rynofinn/apps.git (fetch)
origin  git@github.com:rynofinn/apps.git (push)
```

With the configuration in place, the deployment can be managed.

Navigate to the top of the configuration tree, so that the tool can recurse through all the lower directories.
```
$ pwd

/home/myuser/git/apps/inception/base
```


This will delete an existing deployment:
```
$ kustomize build | oc delete -f -
service "inception" deleted
service "inception-proxy" deleted
deployment.apps "inception" deleted
deployment.apps "inception-proxy" deleted
route.route.openshift.io "inception" deleted
```

And this will create a new deployment:
```
$ kustomize build | oc create -f -
service/inception created
service/inception-proxy created
deployment.apps/inception created
deployment.apps/inception-proxy created
route.route.openshift.io/inception created
```

Watch the health of the deployment from the openshift web console for the namespace.


### Generalize the deployment for other clusters with overlays
The base definition of the deployment needs no changes in the overlays in this instance.  All the details that change between deployments to different clusters are contained in the secrets which hold the configuration for the proxy and inception.


The details in those secrets which change for different deployments are:

- Database credentials
- Network route to the service
- Authentication service used by the reverse proxy


Generate pull request for deployment configuration
https://github.com/operate-first/apps/pull/2527


### Add the Inception application to ArgoCD control
- TODO
