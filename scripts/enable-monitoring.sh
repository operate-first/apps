 #!/bin/sh

set -o errexit
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o errtrace
set -o pipefail

if [ $# -ne 1 ] || [ "$#" == "--help" ] || [ "$#" == "-h" ]; then
    echo "Enable monitoring on a namespace"
    echo -e "\nUsage: $0 NAMESPACE\n"
    exit 0
fi

APP_NAME="cluster-scope"
NAMESPACE=$1

add_rbac_component() {
	pushd $APP_NAME/base/namespaces/$NAMESPACE > /dev/null
	kustomize edit add component ../../../components/monitoring-rbac
	popd > /dev/null
}

if [ ! -d $APP_NAME/base/namespaces/$NAMESPACE ]; then
	echo "Namespace '$NAMESPACE' does not exist in $APP_NAME/base/namespace/. Exiting."
	exit 1
fi

add_rbac_component
