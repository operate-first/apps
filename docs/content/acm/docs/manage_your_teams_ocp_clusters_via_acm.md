# Managing your team's ocp clusters via ACM

We use ACM [managed cluster sets][1] to organize our clusters. When a team is looking to create, import, or manage a cluster
using the Operate First ACM instance (and thus make it part of the Operate First Cloud), they can do so by creating their
own `ManagedClusterSet`. Once a team is given admin access to their `ManagedClusterSet`, they can then create and manage
clusters in this `ManagedClusterSet`, isolated from other clusters within ACM.


## Steps

1. Fork/Clone the [apps repo][2]
2. Navigate to: `acm/overlays/moc/infra/managedclustersets`
3. Create a new `clusterset` like so:

```yaml
kind: ManagedClusterSet
apiVersion: cluster.open-cluster-management.io/v1alpha1
metadata:
  name: <YOUR-CLUSTER-SET-NAME> # A team/org name is ideal
spec: {}
```
Name it `<YOUR-CLUSTER-SET-NAME>.yaml`.

4. Add `<YOUR-CLUSTER-SET-NAME>.yaml` `clusterset` to the `kustomization.yaml` to `acm/overlays/moc/infra/managedclustersets/kustomization.yaml`.
5. Enable GitOps via ArgoCD and Cluster Authentication via [Identitatem][] by doing the following:

Create a `ManagedClusterSetBinding`:

```yaml
apiVersion: cluster.open-cluster-management.io/v1alpha1
kind: ManagedClusterSetBinding
metadata:
  name: <YOUR-CLUSTER-SET-NAME>
spec:
  clusterSet: <YOUR-CLUSTER-SET-NAME>
```

Name this file `<YOUR-CLUSTER-SET-NAME>.yaml` and add it to `acm/overlays/moc/infra/managedclustersetbindings/base`.

This will deploy `ManagedClusterSetBinding` in the `argocd` and `idp-auth-primary` namespaces.

That's it for enabling ArgoCD. All clusters added in your `ManagedClusterSet` by default will be picked up by our ArgoCD
instance. However, to configure your cluster to enable auth via our IDP [AuthRealm][] you will need to add the `label`
`authdeployment: primary` to your clusters' `ManagedCluster` resource. You can do this via GitOps after importing your
cluster via ACM UI, then following the instructions [here][adding_mc].

6. Create the following `ClusterRoleBinding`:

```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: open-cluster-management:managedclusterset:admin:<YOUR-CLUSTER-SET-NAME>
subjects:
  - kind: Group
    apiGroup: rbac.authorization.k8s.io
    name: <YOUR_OCP_GROUP>
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: open-cluster-management:managedclusterset:admin:<YOUR-CLUSTER-SET-NAME>
```

Replace `<YOUR-CLUSTER-SET-NAME>` with the same name used in (3).
Replace `<YOUR_OCP_GROUP>` with your team's ocp group. You can find your group at `${APPS_REPO}/cluster-scope/base/user.openshift.io/groups`.

Name this file `clusterrolebinding.yaml`, and add it to this path
`cluster-scope/base/rbac.authorization.k8s.io/clusterrolebindings/open-cluster-management:managedclusterset:admin:<YOUR-CLUSTER-SET-NAME>`.
Also add this `kustomization.yaml` file in the same path:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- clusterrolebinding.yaml
```

7. Add the following line to the `kustomization.yaml` here `cluster-scope/overlays/prod/moc/infra/kustomization.yaml`:
```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
    - ...
    # Add this line alphabetically, once again replace <YOUR-CLUSTER-SET-NAME> with your ManagedClusterSet name specified in (3)
    - ../../../../base/rbac.authorization.k8s.io/clusterrolebindings/open-cluster-management:managedclusterset:admin:<YOUR-CLUSTER-SET-NAME>
    - ...
```

8. Add your group to the _self-provisioners_ `ClusterRoleBinding` by appending this file
`cluster-scope/overlays/prod/moc/infra/clusterrolebindings/self-provisioners_patch.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: self-provisioners
subjects:
...
    # add your entry here:
    - apiGroup: rbac.authorization.k8s.io
      kind: Group
      name: <YOUR_OCP_GROUP> # Use the same value as in Step 5.
```

> Note: This is a workaround for https://github.com/operate-first/support/issues/436

> Please do not manually create namespaces in the infra cluster, this should be done via filing an issue [here][3].

Commit your changes, make a PR, once merged, ArgoCD will deploy these changes and the team should now be able to
create/manage clusters in this ManagedClusterSet.

[1]: https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.3/html/clusters/managedclustersets#creating-a-managedclusterset
[2]: https://github.com/operate-first/apps
[3]: https://github.com/operate-first/support/issues/new?assignees=first-operator&labels=kind%2Fonboarding%2Carea%2Fcluster&template=onboarding_to_cluster.yaml&title=NEW+PROJECT%3A+%3Cname%3E
[Identitatem]: https://identitatem.github.io/idp-mgmt-docs/
[AuthRealm]: https://github.com/operate-first/apps/blob/master/acm/overlays/moc/infra/identitatem/authrealms/primary.yaml
[adding_mc]: adding_managed_cluster_to_argocd.md
