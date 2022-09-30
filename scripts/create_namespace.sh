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
  --ext-str NAMESPACE \
  --ext-str REQUESTER \
  --ext-str DISPLAY_NAME \
  --ext-str PROJECT_OWNER \
  --ext-str ONBOARDING_ISSUE \
  --ext-str DOCS \
  jsonnet/namespace.jsonnet

for src_file in `find $TMP -name '*.yaml'`
do
    # strip the tmp directory from the file name
    file=${src_file#$TMP/}
	dir=$(dirname "${file}")
	mkdir -p "${APPS_DIR}/${dir}"
	cat $src_file | gojsontoyaml > "${APPS_DIR}/${file}"
done

# init the kustomization.yaml file
cd $APPS_DIR/cluster-scope/base/core/namespaces/${NAMESPACE}/
kustomize create --resources namespace.yaml

# set namespace field
kustomize edit set namespace ${NAMESPACE}

# add limits and resourcequota
cd $APPS_DIR/cluster-scope/base/core/namespaces/${NAMESPACE}/
kustomize edit add component ../../../../components/limitranges/default
kustomize edit add component ../../../../components/resourcequotas/small

# add namespace to cluster
cd $APPS_DIR/cluster-scope/overlays/prod/${ENVIRONMENT}/${CLUSTER}
kustomize edit add resource ../../../../base/core/namespaces/${NAMESPACE}


