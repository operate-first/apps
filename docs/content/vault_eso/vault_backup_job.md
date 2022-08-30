# Vault Backup Job

> Note: This document explains the backup job and how it works. If you are looking to restore vault using a backup
> snapshot. Please read [restore vault docs][].

We periodically back up the Vault instance deployed on [Smaug][vault].

The process leverages the `vault operator raft snapshot` command, see Vault docs on more details [here][vaultbackupdocs].

All configuration files can be accessed at [this location][backupjob].

The backup job is a tekton `TaskRun`, that consists of 3 steps:
- Create a vault snapshot using `vault operator raft snapshot save...`
- Sync this snapshot to back up stores (currently we back up to an [OBC][smaugS3Bucket] and [PVC][pvc])
- Clean up old Task Run jobs (we retain a capped number of jobs).

The `TaskRun` is submitted periodically via a CronJob. The Frequency of this Job can be adjusted by directly updating
the [CronJob][] manifest.

Other configurations are also exposed via the [config secret][] manifest. This secret should be updated directly on the
live cluster, as it is not managed by ArgoCD (it would create a circular dependency on Vault).

The TaskRun Step that creates the snapshot does so by directly running commands from the Vault leader pod, this is due
to a [snapshot bug][], requiring that we take the snapshot from the leader node.

## Add another s3 bucket to back up vault in

Identify a unique prefix `<bucket-prefix>` for your bucket. The prefix can be whatever you would like, as long as it's
unique and does not collide with other prefixes in the configurations. We will refer to this prefix as `<bucket-prefix>`.

Navigate to [backupjob-task][]. Append the `task.spec` field with the following entry:

```yaml
    - name: backup-snapshot-to-s3-<bucket-prefix>
      image: quay.io/operate-first/mc:RELEASE.2022-06-17T02-52-50Z
      workingDir: /workspace
      onError: continue
      command:
        - '/utility-scripts/backup-snapshot-to-s3.sh'
        - $(workspaces.snapshots.path)
        - <bucket-prefix>
```

> If appending, do not add `onError: continue` for the final entry, but ensure that the preceding entries have this set.
> We do not currently have alerts configured to notify us when sync job fails, but we also don't want to fail the
> entire job because of issues with backup to one bucket. A workaround is to let the last one fail the task if the step
> fails. Making it visible from the namespace view that something is wrong. If all steps have `onError: continue` set
> then all bucket syncs could fail, and the task may still show as a success.

In the snippet above, replace `<bucket-prefix>` with your chosen prefix.

Navigate to the backup-config secret within the Vault ocp `namespace`. Find this [here][backup-config-secret].

Add the following entries:

```yaml
<bucket-prefix>-s3AccessKey: ""
<bucket-prefix>-s3SecretKey: ""
<bucket-prefix>-s3BucketName: ""
<bucket-prefix>-s3EndPoint: ""
<bucket-prefix>-s3Retention: ""  # e.g. 1d
```
> Note: this must be done on live, because we do not maintain this secret in git, to do so would require to use ESO
> with vault, and that would introduce a circular dependency on the vault backup job.

Done.

[vaultbackupdocs]: https://learn.hashicorp.com/tutorials/vault/sop-backup?in=vault/standard-procedures#single-vault-cluster
[vault]: https://github.com/operate-first/apps/tree/master/vault/overlays/moc/smaug
[backupjob]: https://github.com/operate-first/apps/tree/master/vault/overlays/moc/smaug/backup-job/
[backupjob-task]: https://github.com/operate-first/apps/blob/master/vault/overlays/moc/smaug/backup-job/task.yaml
[CronJob]: https://github.com/operate-first/apps/blob/master/vault/overlays/moc/smaug/backup-job/cronjob.yaml
[config secret]: https://github.com/operate-first/apps/blob/master/vault/overlays/moc/smaug/backup-job/secret.yaml
[smaugS3Bucket]: https://console-openshift-console.apps.smaug.na.operate-first.cloud/k8s/ns/vault/objectbucket.io~v1alpha1~ObjectBucketClaim/opf-vault-snapshots
[pvc]: https://console-openshift-console.apps.smaug.na.operate-first.cloud/k8s/ns/vault/persistentvolumeclaims/vault-snapshots
[snapshot bug]: https://github.com/hashicorp/vault/issues/15258
[restore vault docs]: ./restore_vault.md
[backup-config-secret]: https://console-openshift-console.apps.smaug.na.operate-first.cloud/k8s/ns/vault/secrets/backup-job
