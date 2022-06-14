# Updating OpenMetaData

Instructions on how to upgrade OpenMetaData in Operate First.

Steps:

## Prerequisites

- Have access to Quay.io

## Update Images in Quay

We use Quay to store the images. By default OM community uses docker, but this opens us to rate limiting issues, so we
replicate them in Quay.io. They are found in our [quay repository][quay] with the `om-*` prefix. There are
two images of note: `om-airflow` and `om-server`, for airflow and openmetadata respectively.

When a new release of OM is rolled out we need to update both Airflow (they provide a new image release) and OM.

Push these images to our quay repository.

## Update Images in Manifests

Run a search for `om-airflow` and `om-server` and replace their tag versions with the target version accordingly.

## Update paths

Go to the [deployment patch][patch] and update the versions for the `volumeMounts` to the target version.

## Compare release diffs for notable changes

Go to the [OM release page][om-rel] and compare the diffs between the current and target versions. Look for any
notable changes. The OM community is moving relatively fast, so things like configuration changes are worth looking out
for.

[quay]: https://quay.io/operate-first/
[om-rel]: https://github.com/open-metadata/OpenMetadata/releases
[om-conf]: https://github.com/open-metadata/OpenMetadata/blob/main/conf/openmetadata.yaml
[patch]: ../../../../openmetadata/overlays/osc/osc-cl2/patches/deployments/openmetadata.yaml
