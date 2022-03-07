# Remove a Cluster from Operate First

## Pre-requisites

1. Basic Git/GitHub knowledge
2. Basic Linux knowledge
3. ArgoCD knowledge and admin access to [Operate First ArgoCD][]
4. ACM access to the ManagedClusterSet that this cluster's ManagedCluster
5. Have [kustomize][] and [yq][] installed.

Before getting started complete the following steps:

1. Fork/Clone the Operate-First [apps repo][]. We'll assume `${WORKDIR}` is the location of your clone.
2. Know the name of the environment and cluster you will be looking to remove.
   We will refer to these as `$ENV` and `$CLUSTER` respectively.

Values for `$CLUSTER` can be obtained by running:
```
kustomize build https://github.com/operate-first/apps/acm/overlays/moc/infra/managedclusters?ref=master | yq e -N '.metadata.name' -
```

Similarly values for `$ENV`:

```
curl -sX GET https://api.github.com/repos/operate-first/apps/contents/argocd/overlays/moc-infra/applications/envs | yq e '.[].name' -
```

## Remove all ArgoCD manifests

We will first remove all ArgoCD manifests. This step should take place first, and be submitted as the first PR on its
own. This is to prevent ArgoCD from deleting from removing any manifests that will be removed from the [apps repo][]
repo in the later steps.

Identify your cluster's `app-of-apps` in `apps/argocd/overlays/moc-infra/applications/app-of-apps` and remove it,
for example:

```
rm ${WORKDIR}/argocd/overlays/moc-infra/applications/app-of-apps/app-of-apps-${CLUSTER}.yaml
rm ${WORKDIR}/argocd/overlays/moc-infra/applications/envs/$ENV/$CLUSTER -rf
CLUSTER=$CLUSTER yq -i e 'del(.resources[] | select(. == "app-of-apps-" + env(CLUSTER) + ".yaml") )' ${WORKDIR}/argocd/overlays/moc-infra/applications/app-of-apps/kustomization.yaml
```

If any ArgoCD projects were created as part of this cluster that you feel are no longer needed, please remove those as
well, they are found in: `argocd/overlays/moc-infra/projects`. Remember to remove them from the `kustomization.yaml`
as well. Please make sure that no other ArgoCD applications belong to this project that were not removed as part of
the earlier deletion commands.

Submit a PR, once merged, you will need to look for the `argocd-infra` application, and manually sync these changes,
as this ArgoCD app does not have Auto Sync enabled. Please only sync changes introduced from this PR, and confirm that
all ArgoCD apps associated with this cluster were successfully removed. Once done proceed to the next steps.

### Detach this cluster from ACM

Navigate to the [ACM console][]. Find your cluster under `Clusters` in the left panel. Click `Actions` at the top right
and select `Detach cluster`. Wait until ACM successfully removes this cluster from the cluster list.

## Remove all manifests belonging to this cluster from the apps repo:

Go back to your [apps repo][] clone at `${$WORKDIR}`, and remove all application manifests in this repo:
```
$ rm ${WORKDIR}/*/overlays/${ENV}/${CLUSTER} -rf
$ rm ${WORKDIR}/cluster-scope/overlays/prod/${ENV}/${CLUSTER} -rf
```

If this was the only cluster in `${ENV}`, go ahead and remove `${WORKDIR}/cluster-scope/overlays/prod/${ENV}`.

```
$ rm ${WORKDIR}/cluster-scope/overlays/prod/${ENV}
```

## Cleanup ACM manifests

Navigate to the `ACM` folder in [apps repo][]:

```
$ cd ${WORKDIR}/acm/overlays/moc/infra
```

Remove the cluster's ManagedCluster if it exists:

```
# First inspect the `managedcluster` to see if it's part of a ManagedClusterSet, remember this value
$ MANAGED_CLUSTER_SET=`cat managedclusters/${CLUSTER}.yaml | grep cluster.open-cluster-management.io/clusterset`

# Now remove it
$ rm managedclusters/${CLUSTER}.yaml
$ CLUSTER=$CLUSTER yq -i e 'del(.resources[] | select(. == env(CLUSTER) + ".yaml") )' managedclusters/kustomization.yaml
```

Look to see if the ManagedClusterSet that this cluster belonged to has any other clusters belonging to it.

You can confirm whether any other clusters belong to the `ManagedClusterSet` by running a simple grep like:

```
$ kustomize build managedclusters | grep "${MANAGED_CLUSTER_SET}"
```

If this was the only cluster, then also remove the `ManagedClusterSet` and any associated `ManagedClusterSetBindings` found in:

- `acm/overlays/moc/infra/managedclustersetbindings`
- `acm/overlays/moc/infra/managedclustersets`

## Remove from Keycloak

If this cluster was configured with Keycloak remove it by running the following:

```
$ cd ${WORKDIR}/keycloak/overlays/moc/infra/
$ rm clients/${CLUSTER}.enc.yaml
$ CLUSTER=$CLUSTER yq -i e 'del(.files[] | select(. == "clients/" + env(CLUSTER) + ".enc.yaml") )' secret-generator.yaml
```

That should be it, once done commit your changes and submit a PR. The ACM changes can be verified by checking the ArgoCD
app called `ACM-Infra` in the [ACM console][].

[apps repo]: https://github.com/operate-first/apps
[Operate First ArgoCD]: https://argocd.operate-first.cloud/applications
[yq]: https://mikefarah.gitbook.io/yq/
[kustomize]: https://kustomize.io/
[ACM console]: https://multicloud-console.apps.moc-infra.massopen.cloud/multicloud/welcome
