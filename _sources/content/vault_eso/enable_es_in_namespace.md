# Enable External Secrets to a namespace

These are instructions on how Operate First administrators can enable Operate First *managed namespaces* to pull secrets
from vault.

> NOTE: If you are NOT an Operate First Cluster Admin but looking utilize Vault for K8s secret store, please see
> [this doc][vault access] instead to get onboarded.

## Pre-requisites

* Vault admin access to https://vault-ui-vault.apps.smaug.na.operate-first.cloud
* Cluster should be [integrated with opf vault instance][1]
* Namespace admin access
* Know your env and cluster (referred to as `$env` and `$cluster` in this doc)
* Have a working clone of the operate-first/apps repo

## Steps

This only needs to be done once per namespace.

### 1. Enable namespace to fetch secrets from vault

These steps need to be followed only once per namespace:

#### Permit role to access namespace

Navigate to vault: https://vault-ui-vault.apps.smaug.na.operate-first.cloud/ui/vault/access

> Note: If you see Not authorized - permission denied instead of a populated window, please check your membership in the
> appropriate `apps/cluster-scope/overlays/prod/moc/smaug/groups/vault-*` group(s).

Click this cluster's *Auth Method*, example for MOC/Smaug, click `smaug-k8s`.

Find the role `${env}-ops`, for example for Smaug/Infra/Curator clusters this is `moc-ops`, for OSC-Cl1/OSC-Cl2 clusters
this is `osc-ops`. Click it.

Click `Edit Role`.

Scroll to `Bound service account namespaces`.

Enter your namespace you would like to integrate with vault.

#### Add Store and SA to namespace

Navigate to `apps/cluster-scope/overlays/prod/${env}/${cluster}/secret-mgmt` and create a new directory named after
your namespace. In this directory add `kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ${namespace}  # replace with your namespace
resources:
  - ../base
```

Then include this directory in  `apps/cluster-scope/overlays/prod/${env}/${cluster}/secret-mgmt/kustomization.yaml`.

Commit your changes and make a PR.

[1]: enable_cluster_to_eso_and_vault.md
[2]: https://external-secrets.io/v0.5.6/provider-hashicorp-vault/
[vault access]: onboard_team_to_vault.md
