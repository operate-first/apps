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
