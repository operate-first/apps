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

TOPDIR=$(git rev-parse --show-toplevel)
. "$TOPDIR/scripts/common.sh"

NAMESPACE=$1

add_rbac_component() {
	pushd $NAMESPACE_PATH/$NAMESPACE > /dev/null
	kustomize edit add component $COMPONENT_REL_PATH/monitoring-rbac
	popd > /dev/null
}

if [ ! -d $NAMESPACE_PATH/$NAMESPACE ]; then
	echo "Namespace '$NAMESPACE' does not exist in $NAMESPACE_PATH. Exiting."
	exit 1
fi

add_rbac_component
