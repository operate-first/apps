#!/bin/sh

set -o errexit
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o errtrace
set -o pipefail

if [ $# -ne 3 ] ||
        [ "$1" == "--help" ] ||
        [ "$1" == "-h" ] ||
        ([ $1 != "admin" ] && [ $1 != "edit" ] && [ $1 != "view" ]); then
    echo "Binds a given role to a group for specified namespace"
    echo -e "\nUsage: $0 admin/edit/view NAMESPACE OWNER-TEAM\n"
    exit 0
fi

TOPDIR=$(git rev-parse --show-toplevel)
. "$TOPDIR/scripts/common.sh"

ROLE=$1
NAMESPACE=$2
OWNER=$3

create_project_role_rolebinding_files() {
	mkdir -p $COMPONENT_PATH/project-$ROLE-rolebindings/$OWNER
	cat <<-EOF > $COMPONENT_PATH/project-$ROLE-rolebindings/$OWNER/rbac.yaml
	---
	apiVersion: rbac.authorization.k8s.io/v1
	kind: RoleBinding
	metadata:
	  name: namespace-$ROLE-$OWNER
	roleRef:
	  apiGroup: rbac.authorization.k8s.io
	  kind: ClusterRole
	  name: $ROLE
	subjects:
	- apiGroup: rbac.authorization.k8s.io
	  kind: Group
	  name: $OWNER
	EOF
	cat <<-EOF > $COMPONENT_PATH/project-$ROLE-rolebindings/$OWNER/kustomization.yaml
	---
	apiVersion: kustomize.config.k8s.io/v1alpha1
	kind: Component

	resources:
	- ./rbac.yaml
	EOF
	echo "RBAC component successfully created at '$COMPONENT_PATH/project-$ROLE-rolebindings/$OWNER'"
}

add_component_to_namespace(){
	pushd $NAMESPACE_PATH/$NAMESPACE > /dev/null
	kustomize edit add component $COMPONENT_REL_PATH/project-$ROLE-rolebindings/$OWNER
	popd > /dev/null
	echo "RBAC component successfully added to $NAMESPACE_PATH/$NAMESPACE/kustomization.yaml."
}

if [ ! -d $NAMESPACE_PATH/$NAMESPACE ]; then
	echo "Namespace '$NAMESPACE' does not exist in $NAMESPACE_PATH/. Exiting."
	exit 1
fi

if [ ! -d $GROUP_PATH/$OWNER ]; then
	echo "Owner-team '$OWNER' does not exist in $GROUP_PATH/$OWNER. Exiting."
	exit 1
fi

if grep "components/project-$ROLE-rolebindings/$OWNER" $NAMESPACE_PATH/$NAMESPACE/kustomization.yaml; then
	echo "Component 'project-$ROLE-rolebindings/$OWNER' already exists in $NAMESPACE_PATH/$NAMESPACE/ Exiting."
	exit 1
fi

if [ ! -d $COMPONENT_PATH/project-$ROLE-rolebindings/$OWNER ]; then
	create_project_role_rolebinding_files
fi

add_component_to_namespace

