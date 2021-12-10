# Secret management for applications

This onboarding guide will help you set up your application's secrets in a way that will make them consumable by our ArgoCD deployments, while not compromising the resource confidentiality.

## Prerequisites

1. Install GPG and [SOPS][sops]
2. Have ready your own/team-owned secret GPG key that you want to access the encrypted data with

Or use the [toolbox](https://github.com/operate-first/toolbox).

## Obtain OperateFirst GPG public key

Fetch [`0508677DD04952D06A943D5B4DC4116D360E3276` GPG key](https://keys.openpgp.org/search?q=0508677DD04952D06A943D5B4DC4116D360E3276):

```sh
gpg --keyserver keys.openpgp.org --recv 0508677DD04952D06A943D5B4DC4116D360E3276
```

## Create sops file

Create a `.sops.yaml` file within your application manifests repository with the following content:

```yaml
creation_rules:
  - encrypted_regex: "^(data|stringData)$"
    pgp: "0508677DD04952D06A943D5B4DC4116D360E3276, YOUR_TEAM_GPG_KEY_FIGERPRINT"
```

This creation rule specifies:

- `encrypted_regex` instructs SOPS to (by default) encrypt only the `data` or `stringData` properties of resources
- `pgp` specifies which GPG keys to be used for the encryption. Multiple key fingerprints can be specified here separated by a comma. Each of the private GPG key holders to fingerprints specified in this list will be able to decrypt and re-encrypt the resource.

For more details on the SOPS configuration, please consult the [SOPS documentation][sops].

## Encrypting a resource

To encrypt a resource, run the `sops --encrypt/-e` command:

```sh
sops -e path/to/resource.yaml > path/to/resource.enc.yaml
```

Make sure the encrypted resource includes the `0508677DD04952D06A943D5B4DC4116D360E3276` GPG key, otherwise our ArgoCD won't be able to decrypt and apply the resource.

```sh
grep "fp: " path/to/resource.enc.yaml
        fp: 0508677DD04952D06A943D5B4DC4116D360E3276
        fp: YOUR_TEAM_GPG_KEY_FIGERPRINT
```

## Updating a resource

If you hold one of the GPG keys needed for the decryption, SOPS CLI allows you to also update the resource. Be advised: You need to have public keys to all the used GPG keys in your keyring otherwise the encryption after your changes won't be successful. Running the following command, SOPS decrypts the resource and opens it in your default editor. The resource will be reencrypted when the file is save and editor closed:

```sh
sops path/to/resource.enc.yaml
```

## Enabling ArgoCD for decryption

Based on the toolkit you use to structure your manifests with, please follow these guides:

1. For Kustomize manifests, please use `ksops`. Please follow [the upstream documentation for ksops][ksops].
2. For Helm manifests, please use `helm-secrets`. Please follow [the upstream documentation for helm-secrets][hsecrets].

[sops]: https://github.com/mozilla/sops
[gpgkey]: https://keys.openpgp.org/search?q=aicoe-operate-first%40redhat.com
[ksops]: https://github.com/viaduct-ai/kustomize-sops
[hsecrets]: https://github.com/jkroepke/helm-secrets
