# Vault Runbook

A runbook for common issues encountered when operating Vault on Operate First Cloud.

## Missing Client token

Error can be encountered when communicating locally via Vault CLI *or* via the Vault Pods. Error looks like the following:

```bash
Error making API request.

URL: GET http://127.0.0.1:8200/....
Code: 400. Errors:

* missing client token
```

In both situations simply run `vault login` and enter your token.

In the case of the Vault Pods, you should need to do it only once.
The token is saved to: `/home/vault/.vault-token`
Any successive terminal sessions in the pod will use this token.


## Service account unauthorized

When adding a secret store, and ensuring all information about the
auth method is correct, you may encounter the following error
encountered:

```txt
"could not get provider client: unable to log in to auth method: unable to log in with Kubernetes auth: Error making API request.
URL: PUT https://vault-ui-vault.apps.smaug.na.operate-first.cloud/v1/auth/infra-k8s/login
```

One of the causes of this could be the JWT token used to configure
this cluster's auth method has expired.

To resolve this:
1. `oc login` to the cluster where ESO is deployed.
2. run `oc sa get-token eso-vault-auth -n external-secrets-operator`
3. Copy the token
4. Navigate to this cluster's auth method's configuration, under kubernetes configuration enter this token for
   "Token Reviewer JWT" in json format this field is `token_reviewer_jwt`.
5. Try creating the secret store again.

# Could not get provider client: unable to log in to auth method

This error may be seen in the ESO logs when looking to setup a secretstore that fails to authenticate against vault.

One reason this may happen is the serviceaccount [JWT][1] for the target cluster (where the ESO in question resides)
that is used to access the `TokenReview` API to validate other JWT may have been rotated.

There is no clear way to confirm this, but you can run the following command when logged in to the cluster where this
ESO is deployed. Log in to vault via cli, and run:

```
vault write auth/${cluster}-k8s/config \
token_reviewer_jwt=$(oc sa get-token eso-vault-auth -n external-secrets-operator) \
kubernetes_host=$(oc whoami --show-server)
```

This will update the `token_reviewer_jwt` with the new ESO SA that vault can use to validate other JWTs. Try creating
the secretstore again and see if it successfully authenticates (by checking the `.status` field).

[1]: https://www.vaultproject.io/api-docs/auth/kubernetes#parameters

## Failed to look up namespace from the token

When creating a `client_token` via k8s JWT service account token you might get this error message:

```
Error writing data to auth/smaug-k8s/login: Error making API request.

URL: PUT https://vault-ui-vault.apps.smaug.na.operate-first.cloud/v1/auth/smaug-k8s/login
Code: 500. Errors:

* error performing token check: failed to look up namespace from the token: no namespace

```

One of the causes of this might be the creation of a new `client_token` while the cached `client_token` at `$HOME/.vault_token` has been in invalidated.

To fix this just remove the old token with: `rm ~/.vault_token`.
