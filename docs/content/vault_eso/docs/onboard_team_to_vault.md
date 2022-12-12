# Onboard an OCP group to vault


## Pre-requisites

* The OCP team should have gone through the standard [OPF Onboarding process][1]
* Must have vault admin access and token (retrieved via Vault UI)
* Target cluster where k8s secrets will be deployed must have [ESO installed][2].
* Target cluster should also have been [integrated with vault][3]
* Kustomize CLI
* Vault CLI

## Steps

### Set up your environment
Open a terminal, and set up environment by running:

```bash
export VAULT_ADDR="https://vault-ui-vault.apps.smaug.na.operate-first.cloud"
export ENV=<environment-name>  # Associated env where secrets will need to be created (e.g. moc, osc, emea)
export CLUSTER=<cluster-name>  # Associated ocp cluster where secrets will need to be created (e.g. smaug, infra,..)
export OCP_GROUP=<ocp-group-name>
export NAMESPACE_1=<ocp-namespace>
export NAMESPACE_2=<ocp-namespace-2> # Optional
export NAMESPACE_3=<ocp-namespace-3> # Optional
...
```

> Note: if more than one namespace will need its secrets stored in vault,
> add env vars `${NAMESPACE_2}, ${NAMESPACE_3},...` accordingly

Log in to vault:

```bash
vault login -method=token
Token (will be hidden): <YOUR-TOKEN>
```

### Create secretstore
Run the following commands:

```bash
git clone https://github.com/operate-first/apps.git
cd apps/cluster-scope/overlays/prod/${ENV}/${CLUSTER}/secret-mgmt
```

Create namespace resources (repeat for all `${NAMESPACE_N}`).

```bash
mkdir ${NAMESPACE_1} && cd ${NAMESPACE_1}
```

```bash
cat <<EOF >>kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ${NAMESPACE_1}
resources:
  - ../base
patchesStrategicMerge:
  - opf-vault-store.yaml
EOF
```

Create the opf-vault-store.

```bash
cat <<EOF >>opf-vault-store.yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: opf-vault-store
spec:
  provider:
    vault:
      auth:
        kubernetes:
          role: ${OCP_GROUP}
EOF
```

Add to parent kustomization:

```bash
cd .. && kustomize edit add resource ${NAMESPACE_1}
```

*Commit your changes and make a PR.*

> Note: The secretstore will not successfully authenticate until the remainder of the doc is completed.

### Create policy

Create the following *.hcl files. Replace $env accordingly.

> Note:  if you are adding support for multiple namespaces to be able to read secrets from vault
> then update the rules file below as per instructions in the comments

```bash

cat <<EOF >>user_policy.hcl
path "k8s_secrets/data/${ENV}/${CLUSTER}/$NAMESPACE_1/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
}

path "k8s_secrets/metadata/${ENV}/${CLUSTER}/$NAMESPACE_1/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
}

# Repeat the 2 rules above for $NAMESPACE_2, $NAMESPACE_3,.. etc.

path "k8s_secrets/*" {
capabilities = ["list"]
}
EOF
```

Run the following:

```bash
vault policy write ${OCP_GROUP} user_policy.hcl
```

### Create Vault group

Create the vault group and associate the Vault oidc login with this ocp group.

```bash
vault write identity/group name="${OCP_GROUP}" type="external" \
       policies="${OCP_GROUP}" \
       metadata=responsibility="Vault ${OCP_GROUP} users"

vault write identity/group-alias name="${OCP_GROUP}" \
     mount_accessor=$(vault auth list -format=json  | jq -r '."oidc/".accessor') \
     canonical_id="$(vault read /identity/group/name/${OCP_GROUP} -format=json | jq -r '.data.id')"
```

## Verify

Create a secret in this location:

```bash
vault kv put k8s_secrets/${ENV}/${CLUSTER}/${NAMESPACE_1}/example-secret passcode=my-long-passcode
```

Ask a user from the group `${OCP_GROUP}` if they can login via OIDC authentication method and access:

```bash
https://vault-ui-vault.apps.smaug.na.operate-first.cloud/ui/vault/secrets/k8s_secrets/show/${ENV}/${CLUSTER}/${NAMESPACE_1}/example-secret
# Do the same for $NAMESPACE_2, $NAMESPACE_3, etc. if needed
```

The user should now be able to [create external secrets][4]

[1]: https://www.operate-first.cloud/apps/content/cluster-scope/onboarding_project.html
[2]: install_es_operator_in_cluster.md
[3]: enable_cluster_to_eso_and_vault.md
[4]: create_external_secret.md
