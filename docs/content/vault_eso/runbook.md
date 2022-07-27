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
URL: PUT https://vault-ui-vault.apps.smaug.na.operate-first.cloud/v1/auth/morty-k8s/login
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
