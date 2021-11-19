# Update gpg key

## Prerequisites

* sops 3.6+

## Instructions

Export the key

```bash
$ gpg --export-secret-keys "${KEY_ID}" | base64 > private.asc
```

```bash
# From the repo root
$ cd argocd/overlays/${ENV}/secrets/gpg
$ sops secret.enc.yaml
```

Copy the contents of `private.asc` into the `operatefirst.key` field.

Save the file, exit. Commit and make a PR.
