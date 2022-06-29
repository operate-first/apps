# Vault Backup Job

> Note: This document explains the backup job and how it works. If you are looking to restore vault using a backup
> snapshot. Please read [restore vault docs][].

We periodically back up the Vault instance deployed on [Smaug][vault].

The process leverages the `vault operator raft snapshot` command, see Vault docs on more details [here][vaultbackupdocs].

All configuration files can be accessed at [this location][backupjob].

The backup job is a tekton `TaskRun`, that consists of 3 steps:
- Create a vault snapshot using `vault operator raft snapshot save...`
- Sync this snapshot to back up stores (currently we back up to an [OBC][mortys3bucket] and [PVC][pvc])
- Clean up old Task Run jobs (we retain a capped number of jobs).

The `TaskRun` is submitted periodically via a CronJob. The Frequency of this Job can be adjusted by directly updating
the [CronJob][] manifest.

Other configurations are also exposed via the [config secret][] manifest. This secret should be updated directly on the
live cluster, as it is not managed by ArgoCD (it would create a circular dependency on Vault).

The TaskRun Step that creates the snapshot does so by directly running commands from the Vault leader pod, this is due
to a [snapshot bug][], requiring that we take the snapshot from the leader node.

[vaultbackupdocs]: https://learn.hashicorp.com/tutorials/vault/sop-backup?in=vault/standard-procedures#single-vault-cluster
[vault]: https://github.com/operate-first/apps/tree/master/vault/overlays/moc/smaug
[backupjob]: https://github.com/operate-first/apps/tree/master/vault/overlays/moc/smaug/backup-job/
[CronJob]: https://github.com/operate-first/apps/blob/master/vault/overlays/moc/smaug/backup-job/cronjob.yaml
[config secret]: https://github.com/operate-first/apps/blob/master/vault/overlays/moc/smaug/backup-job/secret.yaml
[mortys3bucket]: https://console-openshift-console.apps.morty.emea.operate-first.cloud/k8s/ns/opf-obcs/objectbucket.io~v1alpha1~ObjectBucketClaim/opf-vault-snapshots
[pvc]: https://console-openshift-console.apps.smaug.na.operate-first.cloud/k8s/ns/vault/persistentvolumeclaims/vault-snapshots
[snapshot bug]: https://github.com/hashicorp/vault/issues/15258
[restore vault docs]: ./restore_vault.md
