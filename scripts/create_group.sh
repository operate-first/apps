#!/usr/bin/env bash
set -e
set -x
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR
APPS_DIR=$SCRIPT_DIR/../
RESOURCE_DIR="${APPS_DIR}/cluster-scope/base/user.openshift.io/groups/${GROUP}/"

mkdir -p $RESOURCE_DIR
jinja2 --format=env jinja/group.yaml.jinja jinja/group.env -o $RESOURCE_DIR/group.yaml

# init the kustomization.yaml file
cd $RESOURCE_DIR
kustomize create --resources group.yaml

# add group to common overlay
cd $APPS_DIR/cluster-scope/overlays/prod/common/
kustomize edit add resource ../../../base/user.openshift.io/groups/${GROUP}