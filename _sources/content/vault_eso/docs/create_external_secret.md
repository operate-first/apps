# Create External Secret in Operate First

Use this doc to create an External Secret in one of the Operate First managed clusters.

## Pre-requisite

* Your OCP team was [onboarded to vault][onboard-vault].
* Know the OCP `${NAMESPACE}` where you want to create your k8s secret
* Kustomize CLI
* Vault CLI

## Set up your environment

On your terminal set up your environment

```bash
export VAULT_ADDR="https://vault-ui-vault.apps.smaug.na.operate-first.cloud" # Retrieved after OIDC login via browser
export ENV=<environment-name>  # Associated env where secrets will need to be created (e.g. moc, osc, emea)
export CLUSTER=<cluster-name>  # Associated ocp cluster where secrets will need to be created (e.g. smaug, infra,..)
export NAMESPACE=<ocp-namespace> # Namespace where k8s secret will be deployed
```

Log in to vault:

```bash
vault login -method=token
Token (will be hidden): <YOUR-TOKEN>
```

## Add your secret to Vault

Write to vault by running the following:

```bash
vault kv put k8s_secrets/${ENV}/${CLUSTER}/${NAMESPACE}/example-secret passcode=my-long-passcode
```

## Create External Secret

Create your secret, here is a sample secret you may use:

```bash
cat <<EOF >>es.yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${SECRETNAME}
  namespace: ${NAMESPACE}
spec:
  secretStoreRef:
    name: opf-vault-store
    kind: SecretStore
  target:
    name: ${SECRETNAME}
  dataFrom:
    - extract:
        key: ${ENV}/${CLUSTER}/${NAMESPACE}/example-secret
EOF
```
This is a very basic secret that will create a K8s Secret with a 1:1 mapping of your key/values in vault to the
key/values in your target K8s secret. Refer to the [External Secrets Operator][ESO] docs for more example on what you
can do with the `ExternalSecret` resource.

## Verify

Verify the ES was created

```bash
$ oc get externalsecret
NAME             STORE             REFRESH INTERVAL   STATUS         READY
example-secret   opf-vault-store   1h                 SecretSynced   True
```

You should see a status of `SecreSynced`, if you don't, something in the set up has probably gone wrong, run

```bash
oc get externalsecret example-secret -n ${NAMESPACE} -o yaml
```

Inspect the `status` field and see if anything stands out. If it's unclear, reach out to [support] or the community
slack #support channel.

[support]: https://github.com/operate-first/support
[onboard-vault]: onboard_team_to_vault.md
[ESO]: https://external-secrets.io/v0.6.0-rc1/
