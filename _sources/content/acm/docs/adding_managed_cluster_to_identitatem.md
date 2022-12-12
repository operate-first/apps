# Adding Managed Cluster to Identitatem

You can use our [Identitatem][] instance to automatically configure your cluster's authenticatiion using the Operate First
[Authrealm][].

Doing this would allow users to authenticate your cluster via Operate First Organization's GitHub authentication.

To do this you need to first ensure your `ManagedCluster` exists in the [apps][] repo.

Add the label `authdeployment: primary` to this `ManagedCluster` resource.

Ensure your `ManagedCluster` is part of a `ManagedClusterSet` that is bound to the namespace `idp-auth-primary`.

An easy way to do this would be to add the label `cluster.open-cluster-management.io/clusterset: argocd-managed` to
your `ManagedCluster` resource. Just know that this will also add ArgoCD integration to this cluster (i.e. the OPF
ArgoCD will be able to deploy to this cluster.).

You can also create a new `ManagedClusterSet`, for this you will need to:

* Add the `ManagedClusterSet` [here][clusterset].
* Suppose it's named `$CLUSTERSET` then add the label `cluster.open-cluster-management.io/clusterset: $CLUSTERSET` to
your `ManagedCluster` resource (similar to above).
* Create a `ManagedClusterSetBinding` and add this new `$CLUSTERSET` to its `clusterSet` field. Add this binding [here][bindings].

[apps]: https://github.com/operate-first/apps/tree/master/acm/overlays/moc/infra/managedclusters
[kustomization]: https://github.com/operate-first/apps/blob/master/acm/overlays/moc/infra/managedclusters/kustomization.yaml
[Identitatem]: https://identitatem.github.io/idp-mgmt-docs-upstream/
[Authrealm]: https://github.com/operate-first/apps/blob/master/acm/overlays/moc/infra/identitatem/authrealms/primary.yaml
[clusterset]: https://github.com/operate-first/apps/tree/master/acm/overlays/moc/infra/managedclustersets
[bindings]: https://github.com/operate-first/apps/tree/master/acm/overlays/moc/infra/managedclustersetbindings/base
