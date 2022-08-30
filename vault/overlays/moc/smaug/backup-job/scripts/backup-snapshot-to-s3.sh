#!/bin/sh
set -e

snapshot_pvc_path=$1
bucket=$2
s3EndPoint=$(cat /backup-job/${bucket}-s3EndPoint)
s3AccessKey=$(cat /backup-job/${bucket}-s3AccessKey)
s3SecretKey=$(cat /backup-job/${bucket}-s3SecretKey)
s3Bucket=$(cat /backup-job/${bucket}-s3BucketName)
s3Retention=$(cat /backup-job/${bucket}-s3Retention)

echo "Setting up mc connection to s3 Bucket"
mc alias set store ${s3EndPoint} ${s3AccessKey} ${s3SecretKey} --api S3v4

echo "Syncing contents of ${snapshot_pvc_path}/ to Bucket ${s3Bucket} that are newer than ${s3Retention}"
mc mirror ${snapshot_pvc_path}/ store/${s3Bucket}/ --newer-than ${s3Retention}

echo "Removing files from Bucket ${s3Bucket} that are older than ${s3Retention}"
mc rm -r --force --older-than ${s3Retention} store/${s3Bucket}
echo "Done."

echo "Printing contents of Bucket ${s3Bucket}"
echo "--------------------------------------------"
mc ls store/${s3Bucket}
echo "--------------------------------------------"
echo "Done!"
