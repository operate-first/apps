# Unsealing OPF Vault instance

## Pre-requisites

* OCP Project Admin access to [vault namespace][]
* Access to OPF Vault root token and unseal keys (there will be 5)
  * These are accessible via the Operate First Bitwarden

## Steps

### Verify there are Sealed Pods

To verify if a Vault pod is in a sealed state first check each Vault pods' status:

```bash
$ oc project vault
$ oc get pods
$ oc get pods | { head -1; grep pf-vault-*; }
NAME                                   READY   STATUS      RESTARTS   AGE
opf-vault-0                            1/1     Running     0          8h
opf-vault-1                            0/1     Running     0          8h
opf-vault-2                            1/1     Running     0          8h

```

If any of the pods are not ready, you will see `0/1` under the `READY` column. All pods will appear as `0/1` if they are
sealed, see [here][readiness] for this readiness check.

We can further verify this Vault *pod* is sealed by running:
```bash
$ oc rsh opf-vault-1
$ vault status
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    0/3
Unseal Nonce       n/a
Version            1.9.2
Storage Type       raft
HA Enabled         true
$
```

If you see `Sealed true` like above, we know this pod (aka Vault node) is in a Sealed state.

### Unseal pod

Specify the following Environment Variables. All values available in Operate-First bitwarden, there are 5 unseal keys,
we only need 3 to unseal, pick any 3.:

While rsh'd into the sealed Vault node (i.e. pod) run the following to unseal:

```bash
$ vault operator unseal
Key (will be hidden): <enter-unseal-key-1>
$ vault operator unseal
Key (will be hidden): <enter-unseal-key-2>
$ vault operator unseal
Key (will be hidden): <enter-unseal-key-2>
```

Once done, run the following (while still rsh'd into the pod):

```bash
$ oc exec -ti opf-vault-1 -- vault status
/ $ vault status
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
...
```

Verify that `Sealed` is set to `false`.

Confirm that the Vault node has rejoined the cluster:

```bash
/ $ vault operator raft list-peers
Node                                    Address                                State       Voter
----                                    -------                                -----       -----
09b66090-446e-3974-bcb1-7080dacc07e7    opf-vault-0.opf-vault-internal:8201    follower    true
56796c78-adac-b69e-8a62-c431b17c8b9b    opf-vault-2.opf-vault-internal:8201    leader      true
e58ab8b5-62d7-cc6f-27e0-79656bfb8ab7    opf-vault-1.opf-vault-internal:8201    follower    true
```

If you see the other cluster nodes listed, including the node just unsealed. Then you are done.

### Troubleshooting

* If you encounter `Missing Client token` error, then follow instructions [here][missing-token].
* If there are less than 3 nodes, then it's possible the other nodes are also sealed and the same series of steps need
  to be repeated for that node.
* If there are still less than 3 nodes, some nodes may need to be rejoined to the cluster. Instructions [here].

[vault namespace]: https://console-openshift-console.apps.smaug.na.operate-first.cloud/k8s/cluster/projects/vault
[readiness]: https://github.com/operate-first/apps/blob/master/vault/base/statefulsets/statefulset.yaml#L110
[missing-token]: https://www.operate-first.cloud/apps/content/vault_eso/runbook.html#missing-client-token
[rejoin]: https://www.operate-first.cloud/apps/content/vault_eso/runbook.html#rejoin-a-node
