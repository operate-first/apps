#!/usr/bin/env bash
set -e
set -x
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR
APPS_DIR=$SCRIPT_DIR/../
RESOURCE_DIR="${APPS_DIR}/cluster-scope/base/core/namespaces/${NAMESPACE}/"

cd $RESOURCE_DIR
kustomize edit add resource ../../../../components/project-admin-rolebindings/${GROUP}