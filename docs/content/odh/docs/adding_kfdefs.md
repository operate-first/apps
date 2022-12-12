# Add a new Kfdef

Due to security reasons, we do not allow users to deploy their own `Kfdefs` (see [here][1] for details). However, should users want to request a `Kfdef` to their namespace, they can follow the instructions below for submitting a PR.

Steps:
Let `ENV`, `CLUSTER`, and `NAMESPACE` be the environment, cluster, and namespace you would like to deploy this `Kfdef` to respectively.

1. Fork & Clone https://github.com/operate-first/apps
2. Add your `Kfdef` to `kfdefs/overlays/$ENV/$CLUSTER/$NAMESPACE/kfdef.yaml`, accompanied by a `Kustomization.yaml` that includes the `kfdef.yaml`.
3. Add this `Kfdef` to the `kfdefs/overlays/$ENV/$CLUSTER/kustomization.yaml`
4. Submit a PR

Note:
- Since `Kfdefs` can be used to deploy manifests from external repositories, we only allow repositories that come from trusted sources. In general these are repositories part of the Open Data Hub, Kubeflow, or Operate-First org. Exceptions may apply.
- Please avoid adding cluster-wide operators to your `Kfdef` if they have already been deployed by another `Kfdef`.


[1]: https://github.com/operate-first/apps/issues/206
