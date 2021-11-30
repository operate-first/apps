# Onboarding to a cluster

This document serves as a guide for adding cluster scoped resources of `Namespace` and `Group` kinds. Following steps in this guide should result in a PR against the [operate-first/apps](https://github.com/operate-first/apps) repository.

Currently we support 2 ways to request/perform onboarding to any supported clusters:

1. Make an Onboarding issue request. Use the **Onboarding to Cluster** issue template in [operate-first/support](https://github.com/operate-first/support) repository.
2. Opening a PR with the desired changes. The rest of this doc focuses on this second option. We'd gladly welcome your contributions.

> NOTE: Choosing option 2 requires a PR to be made for onboarding after completing the steps outlined below. The actual
> changes will NOT take affect until after this PR is merged.

## Prerequisites

You will need pre-requisite tools to follow along with this doc, please do one of the following:

- Install our [toolbox](https://github.com/operate-first/toolbox) to have the developer setup ready automatically for you.
- Install the tools manually. You'll need [kustomize](https://kustomize.io/), [sops](https://github.com/mozilla/sops) and [ksops](https://github.com/viaduct-ai/kustomize-sops).

You will also need the `opfcli` install the latest version from [here](https://github.com/operate-first/opfcli/releases).

Please fork/clone the [operate-first/apps](https://github.com/operate-first/apps) repository. **During this whole setup, we'll be working within this repository.**

For successful completion of this guide you need to understand what the aim is. Please have prepared following data:

- Name of the onboarded team.
- Desired namespace name. Please use your team name as a prefix. This will make it easier for you to [onboard to ArgoCD](../argocd-gitops/onboarding_to_argocd.md) later on.
- List of users you'd like to add to your team.
- An optional team GPG key, in case you would like to modify the encrypted list of users of your team later on.

## Recipe

If you want to know more about the overall design please consult the ADR documentation at [operate-first/blueprint](https://github.com/operate-first/blueprint).

In general we store all the cluster-scoped resources in a `cluster-scope` kustomize application within this repository.

## Adding namespaces

For easier [onboard to ArgoCD](../argocd-gitops/onboarding_to_argocd.md) later on, we prefer to follow a name pattern for all our namespaces. Please use your team name as a prefix to the namespace name like so: `$OWNER_TEAM-example-project`.

### Base resources

Please run:

```sh
opfcli create-project $NAMESPACE_NAME $OWNER_TEAM -d $OPTIONAL_PROJECT_DESCRIPTION
```

This command will create:

- A namespace in `cluster-scope/base/core/namespaces/$NAMESPACE_NAME`
- A blank user group for the `$OWNER_TEAM` if it does not exist yet in the `cluster-scope/base/user.openshift.io/groups/$OWNER_TEAM`
- An RBAC component for the project admin role `RoleBinding` in `cluster-scope/components/namespace-admin-rolebinding/$OWNER_TEAM` and maps it to the newly added namespace.

### Enabling namespace deployment to target cluster

```sh
cd cluster-scope/overlays/prod/$ENV/$TARGET_CLUSTER
```

Open the `kustomization.yaml` file in this folder and add `../../base/core/namespaces/$NAMESPACE` to the `resources` field.
We aim to keep this field alphabetically sorted for better human readability:

```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
...
- ../../base/core/namespaces/$NAMESPACE
...

```

### Authenticate via OpenShift
Users are automatically created upon login to the appropriate cluster. This is done by logging in via your GitHub account.

Follow the link on the website at [operate-first.cloud](https://www.operate-first.cloud/), and click the grid icon at the top right, you will see a list of clusters. Clicking a cluster will redirect you to a login page, select `operate-first` and login using your GitHub account.

With the user now created, we will need to provide them with appropriate rbac access to this namespace.

## Giving Users Rbac Permissions

The following steps enable users to access designated cluster/namespaces. This consists of adding users to the appropriate OpenShift groups.

Navigate to `cluster-scope/overlays/prod/$ENV/$TARGET_CLUSTER`.

> Note for moc/zero or moc/infra navigate to `cluster-scope/overlays/prod/moc/common` instead

Create the following resource describing the users in your group:

```yaml
# groups/GROUP_NAME.yaml
apiVersion: user.openshift.io/v1
kind: Group
metadata:
  name: GROUP_NAME
  annotations:
    kustomize.config.k8s.io/behavior: replace
users:
  - USER_1
  - USER_2
```

> Note that the USER_n value is the email used to login via SSO in the preceeding steps.

Encrypt the file with sops. You can find the key to import from [here](https://github.com/operate-first/apps/tree/master/cluster-scope/overlays/prod/moc#secret-management):

```sh
$ sops --encrypt --encrypted-regex="^users$" --pgp="0508677DD04952D06A943D5B4DC4116D360E3276" groups/GROUP_NAME.yaml > groups/GROUP_NAME.enc.yaml
$ grep "fp: " groups/GROUP_NAME.enc.yaml
        fp: 0508677DD04952D06A943D5B4DC4116D360E3276
```

If you or your team needs the ability to decrypt this file, you may include additional PGP key fingerprints in the sops command:

```sh
$ sops --encrypt --encrypted-regex="^users$" --pgp="0508677DD04952D06A943D5B4DC4116D360E3276, YOUR_GPG_KEY_FINGERPRINT" groups/GROUP_NAME.yaml > groups/GROUP_NAME.enc.yaml
$ grep "fp: " groups/GROUP_NAME.enc.yaml
        fp: 0508677DD04952D06A943D5B4DC4116D360E3276
        fp: YOUR_GPG_KEY_FINGERPRINT
```

Explanation to the `sops` command:

- `encrypt` flag encrypts a resource
- `encrypted-regex` value maps to the XPath-like regex to specifies which parts of the file should be encrypted. The rest of the file is left as a plaintext for easier management. In this case we want to encrypt only the `users` property in the file. See the docs [here](https://github.com/mozilla/sops#encrypting-only-parts-of-a-file).
- `pgp` list all the GPG keys which will be used to encrypt this file.

Don't forget to remove the plaintext variant of the resource before staging for a commit:

```sh
rm groups/GROUP_NAME.yaml
```

And list the sops encrypted file in the secret generator file:

```yaml
# secret-generator.yaml
files:
---
- groups/GROUP_NAME.enc.yaml
```

Use sops to edit the encrypted group resource patch as:

> Note you can only do this if you included your pgp key in the step above, otherwise ensure all users are added before first encrypting the file.

```sh
sops groups/GROUP_NAME.enc.yaml
```

Then simply append the list of users with the new users that need to be added.

## Finalize

Please stage your changes and send them as a PR against the [operate-first/apps](https://github.com/operate-first/apps) repository. Make sure:

- Change set includes only your modifications within the `cluster-scope` application.
- Change set may include your optional changes to the `.sops.yaml` file.
- Your commit **doesn't include any sensitive data such as an unencrypted resource**, such resources should be included only as encrypted.
