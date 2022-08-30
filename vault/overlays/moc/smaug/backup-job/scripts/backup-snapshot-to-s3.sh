#!/bin/sh
set -e

mortyS3EndPoint=$(cat /backup-job/mortyS3EndPoint)
mortyS3AccessKey=$(cat /backup-job/mortyS3AccessKey)
mortyS3SecretKey=$(cat /backup-job/mortyS3SecretKey)
mortyS3Bucket=$(cat /backup-job/mortyS3BucketName)
mortyS3Retention=$(cat /backup-job/mortyS3Retention)
PVCRetention=$(cat /backup-job/PVCRetention)

snapshot_pvc_path=$1

echo "Setting up mc connection to S3 Bucket"
mc alias set store ${mortyS3EndPoint} ${mortyS3AccessKey} ${mortyS3SecretKey} --api S3v4

echo "Syncing contents of ${snapshot_pvc_path}/ to Bucket ${mortyS3Bucket} that are newer than ${mortyS3Retention}"

mc mirror ${snapshot_pvc_path}/ store/${mortyS3Bucket}/ --newer-than ${mortyS3Retention}

echo "Removing files from Bucket ${mortyS3Bucket} that are older than ${mortyS3Retention}"

mc rm -r --force --older-than ${mortyS3Retention} store/${mortyS3Bucket}

echo "Printing contents of Bucket ${mortyS3Bucket}"

echo "--------------------------------------------"
mc ls store/${mortyS3Bucket}
echo "--------------------------------------------"

echo "Removing files from PVC that are older than ${PVCRetention} in path ${snapshot_pvc_path}"
mc rm -r --force --older-than ${PVCRetention} ${snapshot_pvc_path}/

echo "Printing contents of PVC"

echo "--------------------------------------------"
ls ${snapshot_pvc_path} -lha
echo "--------------------------------------------"

echo "Done!"