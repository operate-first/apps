# Where and How do I add notifications to my ArgoCD apps?

Docs: https://argocd-notifications.readthedocs.io/en/latest/

Currently we deploy ArgoCD-Notifications alongside argocd (same namespace).

## Where and How do I add notifications to my ArgoCD apps?

There are either 2 or 3 main things (depending on the specific notification service(s) used in question) needed if to connect a notification service to argocd notifications.

1. Application annotations:

  - Annotations can be added manually in a application manifest, or use the `oc patch`  command:
```sh
oc patch app <app_name> -n <namespace -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-succeeded.github":""}}}' --type merge
```

  - NOTE: This example has no value, which is actually correct for the github service. It doesn't need any information there because it identifies the application by `appId`, `installationId`, and `privateKey`. However this varies per service type. For instance the slack integration uses the name of the channel to send to as its value. Also note that in that example `on-sync-succeed` is the trigger name, and `github` refers to the service type.

  - Operate-first's Application manifests for apps deployed via argo under [this directory](https://github.com/operate-first/apps/tree/master/argocd/overlays/moc-infra/applications/envs) per environment.

2. A Configmap with the proper components

    - [ ] trigger

    - [ ] template

    - [ ] service (defines the serivce credentials and configuarations so that Argocd-Notifications can use them when executing a template with content specific to a notifcation service)

  - These components are all defined in [this configmap](https://github.com/operate-first/apps/blob/master/argocd-notifications/base/configmap.yaml), although a different configmap could be defined for each notification service and merged into a single configmap using volumes/volumeMounts. Argocd-Notifications by default looks for the configmap named `argocd-notifications-cm`, and the same is true for secrets `argocd-notifications-secret`.

3. An application specific to the notification service desired.

  - Examples of this would be both github and slack. They require the creation of app that they host. This is what gives the tokens or private information that is specificed in the service.

  - Note: if you are doing something that requires an application, make certain that you have enabled the permisions to accoplish what you are aiming for in that application. See [Github's Application Permissions Docs](https://docs.github.com/en/rest/reference/permissions-required-for-github-apps) for an example.

## References

This is reference material related to ArgoCD-Notifications. It goes more into depth about components. [Triggers](https://github.com/operate-first/apps/blob/master/docs/content/argocd-gitops/argocd-notifications.md#Triggers) and [Templates](https://github.com/operate-first/apps/blob/master/docs/content/argocd-gitops/argocd-notifcations.md#Templates) are both resources speicifc to ArgoCD-Notifications, while [Application Annotations](https://github.com/operate-first/apps/blob/master/docs/content/argocd-gitops/argocd-notifications.md#Application-Annotations) covers how this ArgoCD resource (Application manifests) are utilized in ArgoCD-Notifications.

### Application Annotations

  Argocd notifcations utilizes annotations on the application manifest managed by argocd, to know which applications use which trigger and service to subscribe to. The triggers themselves are what call specific templates based on their conditions.

  - Example:
``` yaml
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      annotations:
        notifications.argoproj.io/subscribe.on-sync-succeeded.slack: "argocd-notifications"
        notifications.argoproj.io/subscribe.on-sync-failed.googlechat: "opf-argocd-notifications"
        notifications.argoproj.io/subscribe.<trigger_name>.<service>: <value_if_any_required>
      name: cluster-resources-smaug
      namespace: argocd
```

  As this is in initial deployment stages for this application manifests are modified manually rather than patching them from this dir. For an example, see [cluster resources](https://github.com/operate-first/apps/blob/master/argocd/overlays/moc-infra/applications/envs/moc/smaug/cluster-management/cluster-resources.yaml).

### Triggers

  Triggers require two key values, a `when` condition, which states what data from argocd will start the trigger, and a `send` value which contains an array of template names to call when that trigger fires. Other fields can be added like `description`, or `oncePer`, which tells argocd to only fire the trigger one time per value for the parameter passed in. This is utilized currently in the [slack configmap](https://github.com/operate-first/apps/blob/master/argocd-notifications/base/configmap.yaml#L32) to only allow one success of sync-start per run of a Commit SHA. Because the run trigger will hit before any of the others, it fires the sync run template, and the stacks all the other sync-status notifications (such as failed, degraded, etc.) as replies. Triggers are implemented in such a way that they are notification-service agnostic, because they only listen for conditions in argocd and then call templates when those conditions resolve true.

  More documentation to come, for now see [the docs](https://argocd-notifications.readthedocs.io/en/stable/triggers/).

### Templates

  Templates are what will generate the notification content itself, and works using the html/template golang package. Templates can be referenced by multiple triggers. Additionally one template can work for multiple services, provided everything else is also set up properly. It does this by using its `<template_name>.message` property, which will work with almost all mediums of communication (not sure about webhooks). All the other top level properties in a template are notification-service specific and will only render in that given service type (github, slack, googlechat, etc.). All of Operate-First's trigger templates and trigger names can be found [here](https://github.com/operate-first/apps/blob/master/argocd-notifications/base/configmap.yaml), and are named the same ones as the argocd-notifications catalog. They are not protected values, triggers and templates can be named anything. Additionally other values can be passed into the templates through the `data.context` value of the [configMap](https://github.com/operate-first/apps/blob/master/argocd-notifications/base/configmap.yaml), which does not come from argocd. This is useful for specifying different environments, where one can patch the overlay with argocd-server route.

  More documentation and examples to come, for now see [the docs](https://argocd-notifications.readthedocs.io/en/stable/templates/).

### Notification services / integrations

  [The Docs](https://argocd-notifications.readthedocs.io/en/stable/services/overview/) are the best resource on this topic. Refer to them.
