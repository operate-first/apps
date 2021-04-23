#!/bin/sh

set -o errexit
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o errtrace
set -o pipefail

k=$(find ./kfdefs/base ./observatorium -name kfdef.yaml)

if [ -z "$1" ]; then
   latest_version=$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/opendatahub-io/odh-manifests/releases/latest))
else
   latest_version=$1
fi

echo "updating version is $latest_version"
for kfdef in $k; do
    if ! yq e -e ".metadata.name == \"opendatahub\"" $kfdef 2>&1 >/dev/null; then
        echo skipping $(dirname $kfdef)
        continue
    fi
    echo updating $(dirname $kfdef)

    yq e ".spec.version = \"$latest_version\"" -i $kfdef
    yq e "(.spec.repos.[] | select(.name == \"manifests\").uri = \"https://github.com/opendatahub-io/odh-manifests/tarball/$latest_version\")| \"---\", ." -i $kfdef
done

pushd odh-operator/base
kustomize edit set image quay.io/opendatahub/opendatahub-operator:$latest_version
popd
#end.
