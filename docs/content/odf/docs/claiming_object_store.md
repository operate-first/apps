# Claiming S3-compatible object store buckets

This doc brings a brief summary on how to request a hosted S3 buckets within the Operate First managed deployments. We use the [ODF](https://github.com/red-hat-storage/odf-operator) operator to manage our Ceph storage. We use [Nooba operator](https://github.com/noobaa/noobaa-operator) as part of the OCS platform to provide S3 object store. As such all buckets are to be provisioned using the Noobaa storage class.

## Claim a new bucket

Deploying a following resource within your application will grant you a bucket:

```yaml
apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
  name: CLAIM_NAME # Must be unique: you can't name it the same as any of your secrets or configmap. More details below
spec:
  generateBucketName: CLAIM_NAME-
  storageClassName: openshift-storage.noobaa.io
  additionalConfig:
    maxObjects: "1000"
    maxSize: "2G"
```

You can use `bucketName` property instead of a `generateBucketName` if you wish to set a fixed bucket name. Please be advised that a bucket name must be remain unique in the whole cluster, therefore we would prefer if users either used unique prefixes for the bucket names or refrained from using `bucketName` property (use the `generateBucketName` instead please).

Once deployed and bound, the `ObjectBucketClaim` resource will be updated. Additionally a new `Secret` and a `ConfigMap` are created in the same namespace. **Both the secret as well as the configmap use the same name as the claim resource. Please make sure you don't overwrite any of your current secrets/configmaps.**

### Secret

The auto created secret `CLAIM_NAME` contains 2 properties, which provide access credentials for this bucket:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### ConfigMap

The auto created configmap `CLAIM_NAME` contains 4 additional properties, which specifies means to access the bucket:

- `BUCKET_HOST` which corresponds to an internal cluster route to the Noobaa service (usually `s3.openshift-storage.svc`)
- `BUCKET_NAME` which holds the unique name (in the cluster) of the bucket, prefixed with what was specified in `spec.generateBucketName` of the `ObjectBucketClaim`
- `BUCKET_PORT`
- `BUCKET_REGION`
- `BUCKET_SUBREGION`

### Usage in deployment

In order to use the bucket within your deployment, you can import the information from the `Secret` and `ConfigMap` as environment variables:

```yaml
...
spec:
  containers:
    - name: mycontainer
      ...
      envFrom:
        - configMapRef:
            name: CLAIM_NAME
        - secretRef:
            name: CLAIM_NAME
```

Alternately, you could expose these values as files on the filesystem
by creating volumes [from the `Secret`][secret-vol] and
[from the `ConfigMap`][configmap-vol].

[secret-vol]: https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod
[configmap-vol]: https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#populate-a-volume-with-data-stored-in-a-configmap

## External access

Accessing S3 bucket from outside of the cluster is possible using the
`s3` route exposed in `openshift-storage` namespace. For example, when
logged into the `smaug` cluster:

```sh
$ echo $(oc -n openshift-storage get route s3 -o jsonpath='{.spec.host}')
s3-openshift-storage.apps.smaug.na.operate-first.cloud
```

## Resources and links

- [OpenShift Data Foundation Documentation](https://access.redhat.com/documentation/en-us/red_hat_openshift_data_foundation/4.10/html/managing_hybrid_and_multicloud_resources/object-bucket-claim)
