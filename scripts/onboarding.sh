#!/bin/sh
if [ $# -le 1 ] || [ "$#" == "--help" ] || [ "$#" == "-h" ]; then
	echo "Populate the namespace resource definition."
	echo -e "\nUsage: $0 namespace owner-team [description]\n"
	exit 0
fi

APP_NAME="cluster-scope"
NAMESPACE=$1
OWNER=$2
DESCRIPTION=$3

create_namespace() {
	mkdir -p $APP_NAME/base/namespaces/$NAMESPACE
	cat <<-EOF > $APP_NAME/base/namespaces/$NAMESPACE/namespace.yaml
	---
	apiVersion: v1
	kind: Namespace
	metadata:
	  annotations:
	    openshift.io/display-name: "$DESCRIPTION"
	    openshift.io/requester: $OWNER
	  name: $NAMESPACE
	spec: {}
	EOF
	cat <<-EOF > $APP_NAME/base/namespaces/$NAMESPACE/kustomization.yaml
	---
	apiVersion: kustomize.config.k8s.io/v1beta1
	kind: Kustomization

	namespace: $NAMESPACE

	resources:
	- namespace.yaml

	components:
	- ../../../components/project-admin-rolebindings/$OWNER
	EOF
	echo "Namespace base created at '$APP_NAME/base/namespaces/$NAMESPACE'."
}

create_project_admin_rolebinding() {
	mkdir -p $APP_NAME/components/project-admin-rolebindings/$OWNER
	cat <<-EOF > $APP_NAME/components/project-admin-rolebindings/$OWNER/rbac.yaml
	---
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
	cat <<-EOF > $APP_NAME/components/project-admin-rolebindings/$OWNER/kustomization.yaml
	---
	apiVersion: kustomize.config.k8s.io/v1alpha1
	kind: Component

	resources:
	- ./rbac.yaml
	EOF
	echo "RBAC component successfully created at '$APP_NAME/components/project-admin-rolebindings/$OWNER'."
}

create_group() {
	mkdir -p $APP_NAME/base/groups/$OWNER
	cat <<-EOF > $APP_NAME/base/groups/$OWNER/group.yaml
	---
	apiVersion: user.openshift.io/v1
	kind: Group
	metadata:
	  name: $OWNER
	users: []
	EOF
	cat <<-EOF > $APP_NAME/base/groups/$OWNER/kustomization.yaml
	---
	apiVersion: kustomize.config.k8s.io/v1beta1
	kind: Kustomization

	resources:
	- ./group.yaml
	EOF
	echo "Group '$OWNER' created at '$APP_NAME/base/groups/$OWNER'."
}


if [ -d $APP_NAME/base/namespaces/$NAMESPACE ]; then
	echo "Namespace '$NAMESPACE' already exists in $APP_NAME/base/namespace/. Exiting."
	exit 1
fi

echo "Creating namespace '$NAMESPACE' in the base..."
create_namespace

if [ ! -d $APP_NAME/components/project-admin-rolebindings/$OWNER ]; then
	echo "RBAC for '$OWNER' group does not exist yet. Creating..."
	create_project_admin_rolebinding
fi

if ! grep -r -q "name: $OWNER" "$APP_NAME/base/groups/"; then
	echo "Group for '$OWNER' does not exist yet. Creating..."
	create_group
fi
