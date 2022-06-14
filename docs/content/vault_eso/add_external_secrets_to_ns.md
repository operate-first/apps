# Add External Secrets to a namespace

These are instructions on how Operate First administrators can enable Operate First managed namespaces to pull secrets
from vault. We do not currently offer support for using Operate First Vault instance for the general public.

## Pre-requisites

* Vault access to https://vault-ui-vault.apps.smaug.na.operate-first.cloud
* Cluster should be [integrated with opf vault instance][1]
* Namespace admin access
* Know your env and cluster (referred to as `$env` and `$cluster` in this doc)

## Steps

There are 2 steps:

### Enable Namespace to pull from vault

These steps need to be followed only once per namespace:

### Permit role to access namespace

Navigate to vault: https://vault-ui-vault.apps.smaug.na.operate-first.cloud/ui/vault/access

Click this cluster's *Auth Method*, example for MOC/Smaug, click `smaug-k8s`.

Find the role `${env}-ops`, for example for Smaug/Infra/Curator clusters this is `moc-ops`, for OSC-Cl1/OSC-Cl2 clusters
this is `osc-ops`. Click it.

Click `Edit Role`.

Scroll to `Bound service account namespaces`.

Enter your namespace you would like to integrate with vault.

### Add Secret Store

Add this secret store to your namespace:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: opf-vault-store
spec:
  provider:
    vault:
      auth:
        kubernetes:
          mountPath: ${cluster}-k8s # Ex. 'balrog-k8s', 'smaug-k8s', 'osc-cl1-k8s'
          role: ${env}-ops
          serviceAccountRef:
            name: vault-secret-fetcher
      path: k8s_secrets
      server: 'https://vault-ui-vault.apps.smaug.na.operate-first.cloud'
      version: v2
```

This will allow ESO to authenticate against the vault instance for this particular cluster. Allowing ESO to access
this cluster's secrets in vault.

### Add Service Account

Add this SA to your namespace. Vault is configured to recognize this ServiceAccount name for all integrated clusters.

```yaml
kind: ServiceAccount
apiVersion: v1
metadata:
  name: vault-secret-fetcher
```

ESO will assume this SA's credentials when authenticating with vault.

### Create External Secret

Refer to [ESO Vault Docs][2] on how to create your secret.

Be sure to reference the store we have created above in your secret:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ...
spec:
  secretStoreRef:
    name: opf-vault-store # should match secret store name specified above
    kind: SecretStore
  # Add the rest of your secret templating/spec details here
  # ...

```
[1]: add_cluster_to_eso_and_vault.md
[2]: https://external-secrets.io/v0.5.6/provider-hashicorp-vault/
