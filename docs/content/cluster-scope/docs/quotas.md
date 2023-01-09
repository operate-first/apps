# Adding Resource Quotas

To add a resource quota follow the steps outlined below. Choose one of the pre-defined resource quotas, or create a custom one. You will also need to add a `LimitRange`.

## Adding a resource quota tier to a namespace

Select a tier from [this list][quotas].

Now add this quota to the namespace. For example, if you want to add `small` tier quota to the namespace `argocd` run:

```bash
# From the root of this repo
$ cd cluster-scope/base/core/namespaces/argocd
$ kustomize edit add component ../../../../components/resourcequotas/small
```

## Adding a custom resource quota to a namespace

Create your [own resource][quotas_doc] in the appropriate namespace folder in `cluster-scope/base/core/namespaces/<your_namespace>` name this file `resourcequota.yaml`, ensure that the `.metadata.name` is set to `<namespace_name>-custom`. For example, if you were adding a custom quota to the namespace `argocd` you would run:

```bash
# From the root of this repo
$ cd cluster-scope/base/core/namespaces/argocd
$ kustomize edit add resource ./resourcequota.yaml
```

## Add Limit Range to the namespace

Ensure that a default `LimitRange` is configured if adding a resource quota, otherwise your pods may encounter issues during creation. You can include a `LimitRange` from [here][limit-range]. For example, if adding a `LimitRange` to the `argocd` namespace run the following:

```bash
# From the root of this repo
$ cd cluster-scope/base/core/namespaces/argocd
$ kustomize edit add component ../../../../components/limitranges/default
```

[quotas]:quotas.md
[quotas_doc]:https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/quota-memory-cpu-namespace/
[limit-range]:https://github.com/operate-first/apps/tree/master/cluster-scope/components/limitranges


# Available Resource Quota Tiers

When requesting a namespace, you can choose from 1 of 4 tier options for your resource quota:

|         | CPU Cores | Memory | Storage |
|---------|-----------|--------|---------|
| X-Small |    500m   |   2Gi  |   10Gi  |
| Small   |     1     |   4Gi  |   20Gi  |
| Medium  |     2     |   8Gi  |   40Gi  |
| Large   |     4     |  16Gi  |   80Gi  |

To understand the difference between cpu and memory limits/requests, please refer to [this][k8s-doc].
