# Secret creation using vault CLI and k8s auth

These are instructions on how you can write to our vault instance via the vault CLI using Kubernetes auth.

This might be useful for creating secrets dynamically during a `CronJob` or a `Tekton Task`.

## Pre-requisites
* Install [vault CLI][1] and [jq][4]
* Cluster should be [integrated with opf vault instance][2]
* Admin access to [vault][5]
* Know your cluster, namespace and service account (referred to as `${cluster}`, `${namespace}` and `${service_account}` in this doc)

## Steps

There are 3 steps:

1) Create new role/policy
2) Enable namespace and service account to write secrets to vault
3) Login via vault CLI and create secret

### Create new role/policy

Navigate to vault: https://vault-ui-vault.apps.smaug.na.operate-first.cloud/ui/vault/access

Click the `${cluster}`'s *Auth Method*, example for MOC/Smaug, click `smaug-k8s`.

> Note: If an existing role with a desired policy is present, you don't need to create a new role, just skip to step 2

Click `Create Role`.

Fill in the `Name` and `Alias name source` with the following values:

```
Name=<your_distinct_role_name>
Alias name source=serviceaccount_uid
```

Navigate to `Generated Token's Policies` and enter the name of an existing policy or create a new one.

> Note: If your configuration requires write access to secrets, you most likely need to create a new policy that permits write access

Policies can be viewed or created in the `Policies` tab in the top navigation bar.

For a reference no how to create policies check the [vault documentation on policies](https://developer.hashicorp.com/vault/docs/concepts/policies).

Click `Tokens` at the bottom and then click `Generated Token's Initial TTL` and set it to `3600`

### Enable namespace and service account to write secrets to vault

In your desired role click `Edit Role`.

Navigate to `Bound service account namespaces`.

Enter your `${namespace}` you would like to integrate with vault.

Do the same thing for `Bound service account names` but enter your `${service_account}` that you created in your namespace.

### Login via vault CLI and create secret

Login to a cluster your namespace belongs to with `oc login`.

Get the service account token with

```bash
export SA_TOKEN=$(oc sa get-token ${service_account} -n ${namespace})
```

Set the vault instance address to our instance by exporting the `VAULT_ADDR` environmental variable:


```bash
export VAULT_ADDR=https://vault-ui-vault.apps.smaug.na.operate-first.cloud
```

Get client token with vault cli using the following command:

```bash
vault write auth/${cluster}-k8s/login role=<existing_or_created_role> jwt=$SA_TOKEN -format=json | jq -r '.auth.client_token'
```

This is the only time you will see the token, unless you generate a new one. Make sure you save it in a safe place for future use.

The token can now be used to login via the vault CLI: `vault login ${client_token}`

You can now check if the process worked by issuing this command: `vault status`.

You should now be able to write secrets using the vault cli. To see how to write secrets check the [vault upstream documentation][6].

[1]: https://developer.hashicorp.com/vault/docs/install
[2]: enable_cluster_to_eso_and_vault.md
[3]: add_external_secrets_to_ns.md#1-enable-namespace-to-fetch-secrets-from-vault
[4]: https://stedolan.github.io/jq/download/
[5]: https://vault-ui-vault.apps.smaug.na.operate-first.cloud
[6]: https://developer.hashicorp.com/vault/docs/commands/kv
