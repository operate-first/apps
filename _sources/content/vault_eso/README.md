# Secret Management

We use Vault and External Secrets Operator for managing secrets confidentially in git.

## Vault & ESO
This section contains documentations/instructions on how to interact with the Operate First Cloud Vault and ESO
instance.

Vault URL: https://vault-ui-vault.apps.smaug.na.operate-first.cloud - login with OIDC provider method.

We use [External Secrets Operator (ESO)][external secrets] to manage our secrets declaratively in git.

ESO allows us to store our K8S / OCP secrets in git declaratively without compromising on the security of the platform.

### How can my team use OPF Vault to manage our secrets via GitOps?

If you or your team has a namespace in the OPF cloud, you can use our [External Secrets Operator][ESO] (ESO) to deploy
what are called `ExternalSecrets` (ES) which can be then stored in Git. This `ExternalSecret` contains information about
your `K8s` secret, like where the `data` for your K8s `Secret` resides, what sort of `metadata.annotations` or
`metadata.labels` it should have. The great thing about ES is that they themselves do not contain any confidential data,
so you can store these in Git instead of your `Secret`. See [example] here.

You can learn more about this resource [here][external-secret-cr].

Your actual `Secret` data is stored in our Vault instance. When you deploy your `ES`, ESO will fetch your data from the
path defined in your `ES` and convert that into a K8s secret.

### How to get started?

Assuming your team has gone through the formal onboarding process and your team has an OCP [group] and [namespace] then
you will need to additionally get onboarded by an Operate First Admin. The admins will have to follow the instructions
[here](onboard_team_to_vault.md) to onboard your team. Start by creating an issue [here][support], requesting access to
OPF vault.

Once onboarded, you can follow the instructions [here](create_external_secret.md) to store data in your Vault path,
then create an `External Secret` to fetch this data and convert it to your `Secret`.

[support]: https://github.com/operate-first/support
[group]: https://github.com/operate-first/apps/tree/master/cluster-scope/base/user.openshift.io/groups
[namespace]: https://github.com/operate-first/apps/tree/master/cluster-scope/base/core/namespaces
[external secrets]: https://external-secrets.io
[external-secret-cr]: https://external-secrets.io/v0.6.0-rc1/api/externalsecret/
[example]: https://github.com/operate-first/apps/tree/master/kfdefs/overlays/moc/smaug/trino/externalsecrets
