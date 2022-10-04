#!/usr/bin/env bash
set -e
set -x
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR
APPS_DIR=$SCRIPT_DIR/../

TMP=$(mktemp -d -t tmp.XXXXXXXXXX)

jsonnet -m $TMP -c \
  --ext-str GROUP \
  --ext-code USERS \
  jsonnet/group.jsonnet

for src_file in `find $TMP -name '*.yaml'`
do
    # strip the tmp directory from the file name
    file=${src_file#$TMP/}
	dir=$(dirname "${file}")
	mkdir -p "${APPS_DIR}/${dir}"
	cat $src_file | gojsontoyaml > "${APPS_DIR}/${file}"
done

# init the kustomization.yaml file
cd $APPS_DIR/cluster-scope/base/user.openshift.io/groups/${GROUP}/
kustomize create --resources group.yaml

# add group to common overlay
cd $APPS_DIR/cluster-scope/overlays/prod/common/
kustomize edit add resource ../../../base/user.openshift.io/groups/${GROUP}

# cd $APPS_DIR
# git add cluster-scope
# git diff --cached

