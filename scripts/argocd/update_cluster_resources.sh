#!/bin/sh

set -o errexit
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o errtrace
set -o pipefail

if [ ! -d "cluster-scope" ]; then
  echo "The cluster-scope directory was not found. Please execute this script from the root of the operate-first/app cloned repository."
fi

_BN="$(basename "${0}")"

_usage() {
cat <<HEREDOC

Update ArgoCD cluster resources to specified tag version.

Usage:
  ${_BN}  [tag_version]
  ${_BN}  -h | --help
HEREDOC
}

if [ $# -ne 1 ] || [ "$#" == "--help" ] || [ "$#" == "-h" ]; then
    _usage
    exit 0
fi

http_code=$(curl -s -o /dev/null -w "%{http_code}" https://github.com/argoproj/argo-cd/tree/${1})

if [ ${http_code} -ne "200" ]; then
  echo "Version tag ${1} was not found at https://github.com/argoproj/argo-cd/tree/${1}, exiting."
  exit 1
fi

echo "Synchronizing resources to tag version ${1}"

# CRDS
CRD_PATH=cluster-scope/base/apiextensions.k8s.io/customresourcedefinitions
echo "Updating Cluster CRDs.."
curl -sL -o $CRD_PATH/applications.argoproj.io/customresourcedefinition.yaml \
	https://raw.githubusercontent.com/argoproj/argo-cd/${1}/manifests/crds/application-crd.yaml
curl -sL -o  $CRD_PATH/appprojects.argoproj.io/customresourcedefinition.yaml \
	https://raw.githubusercontent.com/argoproj/argo-cd/${1}/manifests/crds/appproject-crd.yaml

# Clusterroles
ROLE_PATH=cluster-scope/base/rbac.authorization.k8s.io/clusterroles
echo "Updating Cluster ClusterRoles.."
curl -sL -o $ROLE_PATH/argocd-server/clusterrole.yaml \
	https://raw.githubusercontent.com/argoproj/argo-cd/${1}/manifests/cluster-rbac/argocd-server-clusterrole.yaml
curl -sL -o $ROLE_PATH/argocd-application-controller/clusterrole.yaml \
	https://raw.githubusercontent.com/argoproj/argo-cd/${1}/manifests/cluster-rbac/argocd-application-controller-clusterrole.yaml

# ClusterroleBindings
BINDING_PATH=cluster-scope/base/rbac.authorization.k8s.io/clusterrolebindings
echo "Updating Cluster ClusterRoleRolebindings.."
curl -sL -o $BINDING_PATH/argocd-application-controller/clusterrolebinding.yaml \
	https://raw.githubusercontent.com/argoproj/argo-cd/${1}/manifests/cluster-rbac/argocd-application-controller-clusterrolebinding.yaml
curl -sL -o $BINDING_PATH/argocd-server/clusterrolebinding.yaml \
	https://raw.githubusercontent.com/argoproj/argo-cd/${1}/manifests/cluster-rbac/argocd-server-clusterrolebinding.yaml

echo "Done!"
