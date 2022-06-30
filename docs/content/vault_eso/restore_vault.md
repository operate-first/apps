# Restoring vault

## Pre-requisites
* Unseal keys and root token for the snapshot
* Project admin access to the namespace being restored (referred to as `${VAULT_NS}` in this doc)
* Vault CLI

## Steps
* Retrieve the most recent Vault Snapshot from one of the following locations:
  * Snapshot Backup S3 bucket on [Morty Cluster][mortys3bucket]. Use [this s3 endpoint][s3endpoint]
  * Snapshot Backup PVC [here][pvc]. You can use [this pod][toolpod] to access the pvc.
* Login to an OCP cluster
* Go to https://github.com/operate-first/apps/tree/master/vault/overlays
* Find the overlay needing to be deployed
* Navigate to this cluster overlay and run `kustomize build . | oc -n ${VAULT_NS} apply -f -`
* Follow the instructions [here][2], ignoring the `helm install..` portion
  * Use `http://opf-vault-0.opf-vault-internal:8200` when joining `opf-vault-1` and `opv-vault-0`

So far we've installed a new Vault instance, to restore an instance from our old backup:

* Login to the new instance: `vault login -address=$VAULT_ADDR`, use the root token to log in
* Follow the instructions [here][3] to restore the snapshot
* Login to each pod again and unseal using the unseal keys for the snapshot vault.

[1]: https://learn.hashicorp.com/tutorials/vault/sop-backup?in=vault/standard-procedures#single-vault-cluster
[2]: https://www.vaultproject.io/docs/platform/k8s/helm/openshift#highly-available-raft-mode
[3]: https://learn.hashicorp.com/tutorials/vault/sop-restore?in=vault/standard-procedures#single-vault-cluster
[mortys3bucket]: https://console-openshift-console.apps.morty.emea.operate-first.cloud/k8s/ns/opf-obcs/objectbucket.io~v1alpha1~ObjectBucketClaim/opf-vault-snapshots
[s3endpoint]: https://s3-openshift-storage.apps.morty.emea.operate-first.cloud
[pvc]: https://console-openshift-console.apps.smaug.na.operate-first.cloud/k8s/ns/vault/persistentvolumeclaims/vault-snapshots
[toolpod]: https://github.com/operate-first/apps/tree/master/vault/overlays/moc/smaug/backup-job/toolkitpod.yaml
