# Issuing certificates

## Securing OpenShift `Route`s with ACME (Let's Encrypt)

We manage and deploy cluster wide deployment of [OpenShift ACME][1] controller. This operator facilitates [Let's Encrypt][2] certificate provisioning in any `namespace` on the cluster. Any `route` resource is eligible, please use the following annotation to mark the route as managed by this operator:

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  annotations:
    kubernetes.io/tls-acme: "true"
```

Annotating a route will result with an additional temporary route and 2 pods being created in your `namespace`. Once the certificate is issued these pods will be removed. This process is repeated to renew certificates later on.

## Issuing certificates via Cert Manager

For other workloads that rely on SSL/TLS certificates, we will be able to provision certificates via Cert Manager shortly. This is currently work in progress.

[1]: https://github.com/tnozicka/openshift-acme
[2]: https://letsencrypt.org/
