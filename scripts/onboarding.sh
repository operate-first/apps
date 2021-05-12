#!/bin/sh
if [ $# -le 1 ] || [ "$#" == "--help" ] || [ "$#" == "-h" ]; then
	echo "Populate the namespace resource definition."
	echo -e "\nUsage: $0 namespace owner-team [description]\n"
	exit 0
fi

TOPDIR=$(git rev-parse --show-toplevel)
. "$TOPDIR/scripts/common.sh"

NAMESPACE=$1
OWNER=$2
DESCRIPTION=$3

create_namespace() {
	mkdir -p $NAMESPACE_PATH/$NAMESPACE
	cat <<-EOF > $NAMESPACE_PATH/$NAMESPACE/namespace.yaml
	apiVersion: v1
	kind: Namespace
	metadata:
	  annotations:
	    openshift.io/display-name: "$DESCRIPTION"
	    openshift.io/requester: $OWNER
	  name: $NAMESPACE
	spec: {}
	EOF
	cat <<-EOF > $NAMESPACE_PATH/$NAMESPACE/kustomization.yaml
	apiVersion: kustomize.config.k8s.io/v1beta1
	kind: Kustomization

	namespace: $NAMESPACE

	resources:
	- namespace.yaml

	components:
	- $COMPONENT_REL_PATH/project-admin-rolebindings/$OWNER
	EOF
	echo "Namespace base created at '$NAMESPACE_PATH/$NAMESPACE'."
}

create_project_admin_rolebinding() {
	mkdir -p $COMPONENT_PATH/project-admin-rolebindings/$OWNER
	cat <<-EOF > $COMPONENT_PATH/project-admin-rolebindings/$OWNER/rbac.yaml
	apiVersion: rbac.authorization.k8s.io/v1
	kind: RoleBinding
	metadata:
	  name: namespace-admin-$OWNER
	roleRef:
	  apiGroup: rbac.authorization.k8s.io
	  kind: ClusterRole
	  name: admin
	subjects:
	- apiGroup: rbac.authorization.k8s.io
	  kind: Group
	  name: $OWNER
	EOF
	cat <<-EOF > $COMPONENT_PATH/project-admin-rolebindings/$OWNER/kustomization.yaml
	apiVersion: kustomize.config.k8s.io/v1alpha1
	kind: Component

	resources:
	- ./rbac.yaml
	EOF
	echo "RBAC component successfully created at '$COMPONENT_PATH/project-admin-rolebindings/$OWNER'."
}

create_group() {
	mkdir -p $GROUP_PATH/$OWNER
	cat <<-EOF > $GROUP_PATH/$OWNER/group.yaml
	apiVersion: user.openshift.io/v1
	kind: Group
	metadata:
	  name: $OWNER
	users: []
	EOF
	cat <<-EOF > $GROUP_PATH/$OWNER/kustomization.yaml
	apiVersion: kustomize.config.k8s.io/v1beta1
	kind: Kustomization

	resources:
	- ./group.yaml
	EOF
	echo "Group '$OWNER' created at '$GROUP_PATH/$OWNER'."
}


if [ -d $NAMESPACE_PATH/$NAMESPACE ]; then
	echo "Namespace '$NAMESPACE' already exists in $NAMESPACE_PATH/. Exiting."
	exit 1
fi

echo "Creating namespace '$NAMESPACE' in the base..."
create_namespace

if [ ! -d $COMPONENT_PATH/project-admin-rolebindings/$OWNER ]; then
	echo "RBAC for '$OWNER' group does not exist yet. Creating..."
	create_project_admin_rolebinding
fi

if ! grep -r -q "name: $OWNER" "$GROUP_PATH/"; then
	echo "Group for '$OWNER' does not exist yet. Creating..."
	create_group
fi
