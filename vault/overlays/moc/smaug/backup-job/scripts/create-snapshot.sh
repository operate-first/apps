#!/bin/sh
set -e

snapshot_pvc_path=$1
taskrun_namespace=$2

echo "Logging into opf-vault-0 to retrieve leader"

oc exec -i opf-vault-0 -- vault operator raft list-peers --format=json > /tmp/peers.json
leader=$(yq e '.data.config.servers.[] | select(.leader == "true") | .address' -P /tmp/peers.json | cut -d '.' -f1)

echo "retrieved leader: ${leader}"
echo "Creating Snapshot in leader pod ${leader}..."

export snapshot_file_path=$(echo snapshot-"`date +"%F_T%H-%M-%S"`".snap)
oc exec -i $leader -- vault operator raft snapshot save /tmp/backup_job_snapshot.snap

echo "Snapshot created in Vault Leader pod. Moving snapshot from pod to backup PVC."


oc cp ${taskrun_namespace}/$leader:/tmp/backup_job_snapshot.snap ${snapshot_pvc_path}/${snapshot_file_path}
oc exec -i $leader -- rm /tmp/backup_job_snapshot.snap

echo "Backup Snapshot saved at ${snapshot_pvc_path}/$snapshot_file_path"
echo "Listing current snapshots in backedup PVC"

echo "--------------------------------------------"
ls -lha ${snapshot_pvc_path}
echo "--------------------------------------------"

echo "Done!"
