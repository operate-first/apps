# Secret Management

We use Vault and External Secrets Operator for managing secrets confidentially in git.

## Vault & ESO
This section contains documentations/instructions on how to interact with the Operate First Cloud Vault and ESO
instance.

Vault URL: https://vault-ui-vault.apps.smaug.na.operate-first.cloud

We use [External Secrets Operator (ESO)][external secrets] to manage our secrets declaratively in git.

ESO allows us to store our K8S / OCP secrets in git declaratively without compromising on the security of the platform.

[external secrets]: https://external-secrets.io
