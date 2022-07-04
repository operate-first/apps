# Enable Cluster to use External Secrets with Vault

Follow the following steps to use External Secrets Operator with Vault to manage secrets on an OCP cluster.

Note: This is to enable gitops workflow for secrets management for cluster operations, and not user workloads.

## Pre-requisites:
- Know the name of the cluster (e.g. smaug, infra). Referred to as `$cluster` in this doc.
- Know the environment of the cluster (e.g. moc, osc, emea). Referred to as `$env` in this doc.
- Cluster api/ingress must be secured
- Must have cluster admin to said cluster
- Must have access to add auth methods to OPF vault instance, and create policies
- Cluster must be part of the OPF cloud (have associated [cluster-scope folder][cs-folder] and argocd app)
- Have Vault CLI installed
- Have `jq` installed

## Steps:

### Add ESO to the Cluster
Fork and clone the `operate-first/apps` repository.

Add ESO to the cluster by adding to `apps/cluster-scope/overlays/prod/$env/$cluster/kustomization.yaml`
the following line:

```yaml
../../../../bundles/external-secrets-operator
```

Also add `OperatorConfig` from the `base` directory [here][eso] for your `$env/$cluster`. See other sub folders in
`apps/external-secrets/overlays/$env/$cluster`. Yours will look nearly identical.

Add the ArgoCD app to deploy this config to:
`apps/argocd/overlays/moc-infra/applications/envs/$env/$cluster/cluster-management/external-secrets.yaml`

See [more details on adding an app here](../argocd-gitops/add_application.md).

Commit your changes, make a PR. Once merged proceed to the next steps.

### Create Policy with access to the k8s K-V secrets engine

Two types of policies need to be created:
1. A policy for users that will need to add secret data (read-write access)
2. A policy for service accounts to read this data (read-access)

Both policies access the OPF KV (V2) secrets engine mounted at `k8s_secrets`. The clusters' secrets will need to
be stored within the path `k8s_secrets/$env/$cluster/`, so the team and service accounts wishing to store/read for their
clusters' secret will need access to this path.

Create the following `*.hcl` files. Replace `$env` accordingly.
```hcl
# sa_policy.hcl
path "k8s_secrets/data/$env/*" {
  capabilities = ["read", "list"]
}
```

```hcl
# user_policy.hcl
path "k8s_secrets/data/$env/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}


path "k8s_secrets/*" {
  capabilities = ["list"]
}

path "k8s_secrets/metadata/$env/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
}

```

Login to Vault via the CLI and run the following to apply these policies:

```bash
vault policy write ${env}-kv-r sa_policy.hcl
vault policy write ${env}-kv-rw user_policy.hcl
```

### Give OCP users RW access

Check if the Vault group for this ENV exists:

```bash
vault list /identity/group/name | grep vault-admins-${env}
```

If there's no output then you need to create a Vault group that has read/write access to the path `k8s_secrets/data/$env/*`.

```bash
vault write identity/group name="vault-admins-${env}" type="external" \
       policies="${env}-kv-rw" \
       metadata=responsibility="Vault ${env} Admin"

vault write identity/group-alias name="vault-admins-${env}" \
     mount_accessor=$(vault auth list -format=json  | jq -r '."oidc/".accessor') \
     canonical_id="$(vault read /identity/group/name/vault-osc-admins -format=json | jq -r '.data.alias.canonical_id')"
```

This will associate the OCP group named `vault-admins-${env}` with the policy created earlier named `${env}-kv-rw`.
Any Vault user belonging to this OCP group will be able to login using the `OIDC` method and add their secrets to the
path: `k8s_secrets/$env/$cluster/`.

> Note: The OCP group in this context refers to an OCP group found on the OCP cluster where Vault resides.

### Create the K8S Auth Method for ESO
We enabled user login to Vault via OIDC. But we also need to enable k8s auth for the service accounts used by the
Secret Stores managed by ESO. For this we just run the following:

Ensure you are logged into to the target cluster via `oc login`.

First enable the auth method. Each cluster gets their own because Vault will use its `ServiceAccount` with `tokenreview`
permissions to authenticate requests from ESO.

```bash
vault auth enable -path=${cluster}-k8s kubernetes
```

Configure this auth method so that it can review tokens for this cluster.

> Note: For this to work, the api server must have a valid certs.

```bash
vault write auth/${cluster}-k8s/config \
token_reviewer_jwt=$(oc sa get-token eso-vault-auth -n external-secrets-operator) \
kubernetes_host=$(oc whoami --show-server)
```

Create the role for this auth server with a starter SA that can be used to authenticate against this k8s auth method.

```bash
# replace $sa and $sa_namespace accordingly
vault write auth/${cluster}-k8s/role/${env}-ops \
alias_name_source=serviceaccount_uid \
bound_service_account_names=${sa} \
bound_service_account_namespaces=${sa_namespace} \
policies=${env}-kv-r \
ttl=1h
```

You should now be able to use `${sa}` in your `SecretStore`. As long as this `${sa}` is in the namespace `${sa_namespace}`
Then the Secret Store can be authenticate against this vault and fetch secrets from the paths designated by our defined
policies above.

[cs-folder]: https://github.com/operate-first/apps/tree/master/cluster-scope
[eso]: https://github.com/operate-first/apps/tree/master/external-secrets/overlays
