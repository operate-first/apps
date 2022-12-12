# Accessing buckets from outside the cluster

## Creating a bucket

To create a bucket, submit an `ObjectBucketClaim` manifest such as:

```
apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
  name: example-obc
spec:
  generateBucketName: example-obc
  storageClassName: openshift-storage.noobaa.io
```

After submitting this to the cluster, it should shortly become
`Bound`:

```
$ oc get objectbucketclaim
NAME          STORAGE-CLASS                 PHASE   AGE
example-obc   openshift-storage.noobaa.io   Bound   9m9s
```

Once your claim is bound, you will find two additional resources in
your target namespace:

- A `ConfigMap` named after your claim
- A `Secret` named after your bucket

The `ConfigMap` contains the internal hostname for the object storage
API endpoint and the name of your bucket:

```
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app: noobaa
    bucket-provisioner: openshift-storage.noobaa.io-obc
    noobaa-domain: openshift-storage.noobaa.io
  name: example-obc
  namespace: default
data:
  BUCKET_HOST: s3.openshift-storage.svc
  BUCKET_NAME: example-obc-a8f2836a-f80a-4d52-b6f9-16fdc8004b59
  BUCKET_PORT: "443"
  BUCKET_REGION: ""
  BUCKET_SUBREGION: ""
```

The `Secret` contains your credentials:

```
kind: Secret
metadata:
  labels:
    app: noobaa
    bucket-provisioner: openshift-storage.noobaa.io-obc
    noobaa-domain: openshift-storage.noobaa.io
  name: example-obc
  namespace: default
type: Opaque
apiVersion: v1
data:
  AWS_ACCESS_KEY_ID: ...
  AWS_SECRET_ACCESS_KEY: ...
```

## Accessing a bucket from outside the cluster

### Getting the API endpoint

The `ConfigMap` associated with your bucket claim provides the
*internal* hostname for the object storage API. To access the bucket
from outside the cluster, you will need to replace that with with the
externally visible hosting.

With appropriate access, you can run:

```
$ oc -n openshift-storage get route s3 -o jsonpath='{.spec.host}{"\n"}'
```

On the `smaug` cluster, this will return:

```
s3-openshift-storage.apps.smaug.na.operate-first.cloud
```

If you are unable to query the `openshift-storage` namespace, you may
be able to replace `apps.smaug.na.operate-first.cloud` with the
domain appropriate to your cluster.

### Extract bucket information

Extract information from your `Secret` and `ConfigMap` into
environment variables:

```
export BUCKET_ENDPOINT=https://s3-openshift-storage.apps.smaug.na.operate-first.cloud
export BUCKET_NAME="$(oc get configmap example-obc \
  -o jsonpath='{.data.BUCKET_NAME}')"
export AWS_ACCESS_KEY_ID="$(oc get secret example-obc \
  -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 -d)"
export AWS_SECRET_ACCESS_KEY="$(oc get secret example-obc \
  -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 -d)"
```

### Accessing a bucket using the AWS CLI

Assuming you have configured the environment variables described in
the "Extract bucket information" section, you can use the following
`aws` commands to interact with your bucket.

To upload an object to your bucket:

```
aws --endpoint-url $BUCKET_ENDPOINT s3 cp README.md s3://$BUCKET_NAME
```

To list objects in your bucket:

```
aws --endpoint-url $BUCKET_ENDPOINT s3 ls $BUCKET_NAME
```

To download an object from your bucket to a local file:

```
aws --endpoint-url $BUCKET_ENDPOINT s3 cp s3://$BUCKET_NAME/README.md README.md
```

### Accessing a bucket using the MinIO CLI

Assuming you have configured the environment variables described in
the "Extract bucket information" section, create a MinIO alias
definition for your bucket:

```
mcli alias set example-obc $BUCKET_ENDPOINT $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY
```

To upload an object to your bucket:

```
mcli cp README.md example-obc/$BUCKET_NAME/
```

To list objects in your bucket:

```
mcli ls example-obc/$BUCKET_NAME
```

To download an object from your bucket to a local file:

```
mcli cp example-obc/$BUCKET_NAME/README.md README.md
```

### Accessing a bucket using s3cmd

Assuming you have configured the environment variables described in
the "Extract bucket information" section, create a configuration file
for accessing your bucket:

```
cat <<EOF > s3cfg
[default]
access_key = $AWS_ACCESS_KEY_ID
secret_key = $AWS_SECRET_ACCESS_KEY
host_base = ${BUCKET_ENDPOINT##*/}
host_bucket =
EOF
```

To upload an object to your bucket:

```
s3cmd -c s3cfg put README.md s3://$BUCKET_NAME/
```

To list objects in your bucket:

```
s3cmd -c s3cfg ls s3://$BUCKET_NAME
```

To download an object from your bucket to a local file:

```
s3cmd -c s3cfg get s3://$BUCKET_NAME/README.md README.md
```
