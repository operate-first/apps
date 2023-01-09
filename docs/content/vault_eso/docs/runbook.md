# Vault Runbook

A runbook for common issues encountered when operating Vault on Operate First Cloud.

## Pre-requisites
* Unseal keys and root token for the snapshot
* Kustomize CLI
* Vault CLI
* OC CLI

## Missing Client token

Error can be encountered when communicating locally via Vault CLI *or* via the Vault Pods. Error looks like the following:

```bash
Error making API request.

URL: GET http://127.0.0.1:8200/....
Code: 400. Errors:

* missing client token
```

In both situations simply run `vault login` and enter your token. In the case of the Vault Pods, `oc rsh` in to the pod
first by running `oc rsh <vault-pod-name>`.

> Note: For the vault pod, use the root-token acquired via bitwarden.

In the case of the Vault Pods, you should need to do it only once.
The token is saved to: `/home/vault/.vault-token`
Any successive terminal sessions in the pod will use this token.

## Service account unauthorized

When adding a secret store, and ensuring all information about the
auth method is correct, you may encounter the following error
encountered:

```txt
"could not get provider client: unable to log in to auth method: unable to log in with Kubernetes auth: Error making
API request.

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

### Rejoin A Vault node to the Vault cluster

To confirm all nodes are part of the Vault cluster, run the following on all vault pods in `vault` namespace:

```bash
$ oc exec -ti opf-vault-0 -n vault -- vault operator raft list-peers
$ oc exec -ti opf-vault-1 -n vault -- vault operator raft list-peers
$ oc exec -ti opf-vault-2 -n vault -- vault operator raft list-peers
```

*There are 3 possible outputs for each pod:*

A. Only one vault node is listed (itself)
B. There are 2 vault nodes are listed (itself and one more), identify the leader pod
C. All 3 vault nodes are listed

Then there are three possible cases:

*Case 1: All nodes show output (C)*
Everything is good, you are done.

*Case 2: All show output (A)*
If all nodes show (A), then no nodes are part of the cluster, identify one to be the leader and set the following
environment variable: `LEADER=http://<pod-name>.opf-vault-internal:8200` where `<pod-name>` corresponds to your chosen
leader, for example: `LEADER=http://opf-vault-1.opf-vault-internal:8200`.

Join the remaining pod (`opf-vault-0` and `opf-vault-2` in our example) to our chosen leader:

```bash
oc exec -ti opf-vault-0 -- vault operator raft join http://opf-vault-1.opf-vault-internal:820
oc exec -ti opf-vault-2 -- vault operator raft join http://opf-vault-1.opf-vault-internal:820
```

Unseal each of these nodes, instructions [here][unseal].

*Case 3: At least one pod showed 2 nodes in the cluster*
Then the third node needs to be rejoined with the other nodes, identify the leader from the other 2 nodes by running:

Let's assume `opf-vault-0` and `opf-vault-2` are in the same cluster, and `opf-vault-1` is not (i.e. showing a single
node output in `list-peers` command).

```bash
~ $ oc exec -ti opf-vault-1 -- vault operator raft list-peers
Node                                    Address                                State       Voter
----                                    -------                                -----       -----
09b66090-446e-3974-bcb1-7080dacc07e7    opf-vault-0.opf-vault-internal:8201    follower    true
56796c78-adac-b69e-8a62-c431b17c8b9b    opf-vault-2.opf-vault-internal:8201    leader      true
```

When we do the same for `opf-vault-1` we see:

```bash
~ $ oc exec -ti opf-vault-1 -- vault operator raft list-peers
Node                                    Address                                State       Voter
----                                    -------                                -----       -----
e58ab8b5-62d7-cc6f-27e0-79656bfb8ab7    opf-vault-1.opf-vault-internal:8201    leader      true
```

In this example, it's clear that `opf-vault-1` is not part of the main cluster. And `opf-vault-2` is the leader of the
main cluster. So we want to rejoin `opf-vault-1` by running:

```bash
oc exec -ti opf-vault-1 -- vault operator raft join http://opf-vault-2.opf-vault-internal:820
```

Now all 3 nodes should show the following output:

```bash
$ oc exec -ti opf-vault-1 -- vault operator raft list-peers
Node                                    Address                                State       Voter
----                                    -------                                -----       -----
09b66090-446e-3974-bcb1-7080dacc07e7    opf-vault-0.opf-vault-internal:8201    follower    true
56796c78-adac-b69e-8a62-c431b17c8b9b    opf-vault-2.opf-vault-internal:8201    leader      true
e58ab8b5-62d7-cc6f-27e0-79656bfb8ab7    opf-vault-1.opf-vault-internal:8201    follower    true
```

Unseal `opf-vault1` by following the instructions [here][unseal].

We are done.

[unseal]: https://www.operate-first.cloud/apps/content/vault_eso/unsealing_vault.html
