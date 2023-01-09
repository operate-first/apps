# Get access to ArgoCD

Our [ArgoCD][argocd] instance is configured to be accessed read only anonymously.

## Get Admin Access

If you need admin level read/write access, add your GitHub handle to [this group](https://github.com/operate-first/apps/blob/master/cluster-scope/base/user.openshift.io/groups/argocd-admins/group.yaml)

NOTE: All github handles **MUST** be added in lower case to either of these files, or else it will cause issues.

[argocd]: https://argocd.operate-first.cloud
[argocd_onboarding]: onboarding_to_argocd.md
[group_add]: ../cluster-scope/add_user_to_group.md

## CLI access

Download the [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/getting_started/#2-download-argo-cd-cli) and login to the ArgoCD instance using the following command:

```shell
argocd login argocd.operate-first.cloud --sso
```

Now you e.g. list projects via `argocd proj list` or list applications via `argocd app list`.
To find out wether an application has auto sync for its sync policy enabled, check the `Sync Policy` column in the output of `argocd app list` or inspect the json output of `argocd app get <app-name> -o json`.

```
$ argocd app get cluster-resources-jerry -o json | jq '.spec.syncPolicy'
{
  "automated": {
    "prune": true,
    "selfHeal": true
  },
  "syncOptions": [
    "Validate=false",
    "ApplyOutOfSyncOnly=true"
  ]
}

$ argocd app get cluster-resources-smaug -o json | jq '.spec.syncPolicy'
{
  "syncOptions": [
    "Validate=false",
    "ApplyOutOfSyncOnly=true"
  ]
}
```
