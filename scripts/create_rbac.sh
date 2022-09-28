#!/usr/bin/env bash
set -e
set -x
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR
APPS_DIR=$SCRIPT_DIR/../
RESOURCE_DIR="${APPS_DIR}/cluster-scope/components/project-admin-rolebindings/${GROUP}/"

mkdir -p $RESOURCE_DIR
jinja2 --format=env jinja/rbac.yaml.jinja jinja/rbac.env -o $RESOURCE_DIR/rbac.yaml

cd $RESOURCE_DIR
kustomize create --resources rbac.yaml




