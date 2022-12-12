# Adding buckets to Trino

## Prerequisites
- Must be Operate-First admin with SOPS GPG access

## Steps

1. Clone apps repo
2. Navigate to `apps/kfdefs/overlays/$ENV/$CLUSTER/trino/hive-metastores`

> Note: Values for ENV, CLUSTER, TRINO_FOLDER are dependent upon which cluster you are deploying.
> Please explore [kfdefs][kfdefs] overlays folder to identify the values for these variables.

3. Create a new directory which is named after the new Trino catalog you will add, in this example we'll create
a catalog called `some-catalog`, so we create:

```bash
$ cd $APPS_REPO
# Replace dashes with underscores in catalog names, so some-catalog becomes some_catalog
$ mkdir apps/kfdefs/overlays/$ENV/$CLUSTER/trino/hive-metastores/some_catalog
```

Now create a new file in this directory called `kustomization.yaml` and fill it out like so:

```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../../../../../base/trino/hive-metastore-template
patches:
  - target:
      kind: Service
      name: catalog-name
    patch: |
      - op: replace
        path: /metadata/name
        value: hive-metastore-<catalog_name>
      - op: replace
        path: /metadata/labels/trino-catalog
        value: hive-metastore-<catalog_name>
      - op: replace
        path: /spec/selector/trino-catalog
        value: hive-metastore-<catalog_name>
  - target:
      kind: StatefulSet
      name: catalog-name
    patch: |
      - op: replace
        path: /metadata/name
        value: hive-metastore-<catalog_name>
      - op: replace
        path: /metadata/labels/trino-catalog
        value: hive-metastore-<catalog_name>
      - op: replace
        path: /spec/selector/matchLabels/trino-catalog
        value: hive-metastore-<catalog_name>
      - op: replace
        path: /spec/serviceName
        value: hive-metastore-<catalog_name>
      - op: replace
        path: /spec/template/metadata/labels/trino-catalog
        value: hive-metastore-<catalog_name>
      - op: replace
        path: /spec/selector/matchLabels/trino-catalog
        value: hive-metastore-<catalog_name>
      - op: add
        path: /spec/template/spec/containers/0/env/-
        value:
          name: S3_ENDPOINT
          valueFrom:
            secretKeyRef:
              key: <catalog_name_upercase>_S3_ENDPOINT
              name: s3buckets
      - op: add
        path: /spec/template/spec/containers/0/env/-
        value:
          name: S3_ENDPOINT_URL_PREFIX
          valueFrom:
            secretKeyRef:
              key: <catalog_name_upercase>_S3_ENDPOINT_URL_PREFIX
              name: s3buckets
      - op: add
        path: /spec/template/spec/containers/0/env/-
        value:
          name: AWS_ACCESS_KEY_ID
          valueFrom:
            secretKeyRef:
              key: <catalog_name_upercase>_AWS_ACCESS_KEY_ID
              name: s3buckets
      - op: add
        path: /spec/template/spec/containers/0/env/-
        value:
          name: AWS_SECRET_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              key: <catalog_name_upercase>_AWS_SECRET_ACCESS_KEY
              name: s3buckets
      - op: add
        path: /spec/template/spec/containers/0/env/-
        value:
          name: S3_BUCKET_NAME
          valueFrom:
            secretKeyRef:
              key: <catalog_name_upercase>_BUCKET
              name: s3buckets
      - op: add
        path: /spec/template/spec/containers/0/env/-
        value:
          name: S3_DATA_DIR
          value: "data"

```

Replace all instance of `<catalog_name>` with your catalog name, and all instance of `<catalog_name_upercase>` with your catalog
name in upper case and underscores instead of dash/spaces. For example if your catalog name is `some-catalog` you can run the
following `sed` command on your `kustomization.yaml`:

```bash
$ sed -i 's/<catalog_name>/some-catalog/g' kustomization.yaml
$ sed -i 's/<catalog_name_upercase>/SOME_CATALOG/g' kustomization.yaml
```

Also add this directory to the `kustomization.yaml` located at `kfdefs/overlays/$ENV/$CLUSTER/trino/hive-metastores`.

Next add the following to the `s3buckets` secret found at `apps/kfdefs/overlays/$ENV/$CLUSTER/trino/secrets/s3buckets.yaml`.

> Note you will need to use sops to edit this file with the appropriate gpg key

```yaml
    # Fill these values out accordingly
    <catalog_name_upercase>_AWS_ACCESS_KEY_ID:
    <catalog_name_upercase>_AWS_SECRET_ACCESS_KEY:
    <catalog_name_upercase>_BUCKET:
    <catalog_name_upercase>_REGION:
    <catalog_name_upercase>_S3_ENDPOINT:
    <catalog_name_upercase>_S3_ENDPOINT_URL_PREFIX:
```
Use the same value for `<catalog_name_upercase>` as used above. Fill out the values for these fields according to your
s3 bucket details.

Next we need to update Trino Catalog configuration files.

Navigate to: `apps/kfdefs/overlays/$ENV/$CLUSTER/trino/configs/catalogs/`, create a file called
`<catalog_name_underscored>.properties`. With the following contents:

```yaml
connector.name=hive-hadoop2
hive.metastore.uri=thrift://hive-metastore-<catalog_name>:9083
hive.s3.endpoint=${ENV:<catalog_name_upercase>_S3_ENDPOINT_URL_PREFIX}${ENV:<catalog_name_upercase>_S3_ENDPOINT}
hive.s3.signer-type=S3SignerType
hive.s3.path-style-access=true
hive.s3.staging-directory=/tmp
hive.s3.ssl.enabled=false
hive.s3.sse.enabled=false
hive.allow-drop-table=true
hive.parquet.use-column-names=true
hive.recursive-directories=true
hive.non-managed-table-writes-enabled=true
hive.s3.aws-access-key=${ENV:<catalog_name_upercase>_AWS_ACCESS_KEY_ID}
hive.s3.aws-secret-key=${ENV:<catalog_name_upercase>_AWS_SECRET_ACCESS_KEY}
```

Replace all `<*>` values same as above.

Add this file to `apps/kfdefs/overlays/$ENV/$CLUSTER/trino/configs/kustomization.yaml` under the
`configMapGenerator` in the `files` list for `trino-catalog`.

Commit changes, make a pr.

[kfdefs]: https://github.com/operate-first/apps/tree/master/kfdefs/overlays
