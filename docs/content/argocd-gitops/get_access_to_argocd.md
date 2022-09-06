# Get access to ArgoCD

To get access to the Operate First ArgoCD instance (found [here][argocd]), there are two requirements. Firstly, you need to belong to an OpenShift `Group` that has
access to an `ArgoCD Project`. You can find which groups have access by checking the contents of [this file][dex_cm]. Secondly, you need to be a member of the `Operate-First` github ogranization. Documentation on doing this is available [here](https://github.com/operate-first/common/blob/main/docs/add_gh_member_and_access.md#become-a-github-member).

If your OCP `Group` is not listed here then please follow [these instructions][argocd_onboarding] to get your team
onboarded.

If your team is already onboarded to ArgoCD (and thuse listed in `dex.config`) but you are not in it, then please follow
[these instructions][group_add] to get added to your team.


## Get Admin Access

If you need admin level read access, add your GitHub handle to [this group](https://github.com/operate-first/apps/blob/master/cluster-scope/base/user.openshift.io/groups/argocd-readonly/group.yaml)

If you need admin level read/write access, add your GitHub handle to [this group](https://github.com/operate-first/apps/blob/master/cluster-scope/base/user.openshift.io/groups/argocd-admins/group.yaml)

NOTE: All github handles **MUST** be added in lower case to either of these files, or else it will cause issues.

[argocd]: https://argocd.operate-first.cloud
[dex_cm]: https://github.com/operate-first/apps/blob/master/argocd/overlays/moc-infra/configs/argo_cm/dex.config
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
