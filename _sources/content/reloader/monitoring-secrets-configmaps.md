# Monitoring secrets and configMaps for changes with Reloader
For `deployments`, Reloader can be used to monitor `configMap` and `secret` resources for changes. If a change is detected Reloader will trigger a rolling upgrade on relevant pods via the associated `deployment`.

To see the clusters where Reloader is currently available in Operate first visit: [opf clusters with Reloader](https://github.com/stakater/Reloader)

NOTE: `configMap` and `secret` resources must be used via an environment variable, or a volume mount to allow monitoring with Reloader.

## Monitoring changes in configMaps
To perform rolling upgrade when change happens only on specific `configmaps` use below annotation.

For a Deployment have a `configMap` called foo-configmap. Then add this annotation to the main metadata of your `deployment`.

```
kind: Deployment
metadata:
  annotations:
    configmap.reloader.stakater.com/reload: "foo-configmap"
spec:
  template: metadata:

```

You can specify multiple `configMaps` with a comma separated list.

```
kind: Deployment
metadata:
  annotations:
    configmap.reloader.stakater.com/reload: "foo-configmap,bar-configmap,baz-configmap"
spec:
  template:
    metadata:
```

## Monitoring changes in secrets
To perform rolling upgrade when change happens only on specific `secrets` use below annotation.

For a Deployment have a `secret` called foo-secret. Then add this annotation to the main metadata of your Deployment.

```
kind: Deployment
metadata:
  annotations:
    secret.reloader.stakater.com/reload: "foo-secret"
spec:
  template:
    metadata:
```

You can specify multiple `secrets` with a comma separated list.

```
kind: Deployment
metadata:
  annotations:
    secret.reloader.stakater.com/reload: "foo-secret,bar-secret,baz-secret"
spec:
  template:
    metadata:
```

## Resources and links
- [Reloader github page](https://github.com/stakater/Reloader)
- [opf clusters with Reloader](https://github.com/stakater/Reloader)
