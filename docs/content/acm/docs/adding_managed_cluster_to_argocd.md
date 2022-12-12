# Adding Managed Cluster to ArgoCD

To add a managed cluster to ArgoCD, create a `ManagedCluster` called `<cluster_name>.yaml` with the following contents:

```yaml
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: <cluster-name>
  labels:
    cluster.open-cluster-management.io/clusterset: argocd-managed
    # Uncomment the following line if you want to enable GitHub auth (via Operate First org) managed by Identitatem
    # authdeployment: primary
```

> Ensure that the `<cluster-name>` matches that of the `ManagedCluster` resource on live, you can also check for this value
> as it appears on ACM under "Name" when you navigate to Infrastructure > Clusters

Add this file to the `kustomization.yaml` found [here][kustomization].

[kustomization]: https://github.com/operate-first/apps/blob/master/acm/overlays/moc/infra/managedclusters/kustomization.yaml
