#!/bin/sh
set -e

PVCRetention=$(cat /backup-job/PVCRetention)
snapshot_pvc_path=$1

echo "Removing files from PVC that are older than ${PVCRetention} in path ${snapshot_pvc_path}"
mc rm -r --force --older-than ${PVCRetention} ${snapshot_pvc_path}/
echo "Done."

echo "Printing contents of PVC"
echo "--------------------------------------------"
ls ${snapshot_pvc_path} -lha
echo "--------------------------------------------"
echo "Done!"
