# Import Development GPG Key

If you would like to import the GPG key used for dev purposes in our ArgoCD dev deployment, you can find it under: `apps/docs/argocd-gitops/key.asc`. To import it simply run:

```
$ base64 -d < apps/docs/content/argocd-gitops/key.asc | gpg --import
```

You will need to import this key to be able to decrypt the contents of the secrets using sops.

Do NOT use this gpg key for prod purposes.
