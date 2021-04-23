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
echo "Updating Cluster CRDs.."
wget -q https://raw.githubusercontent.com/argoproj/argo-cd/${1}/manifests/crds/application-crd.yaml -O cluster-scope/base/crds/applications.argoproj.io/crd.yaml
wget -q https://raw.githubusercontent.com/argoproj/argo-cd/${1}/manifests/crds/appproject-crd.yaml -O cluster-scope/base/crds/appprojects.argoproj.io/crd.yaml

# Clusterroles
echo "Updating Cluster ClusterRoles.."
wget -q https://raw.githubusercontent.com/argoproj/argo-cd/${1}/manifests/cluster-rbac/argocd-server-clusterrole.yaml -O cluster-scope/base/clusterroles/argocd-server/clusterrole.yaml
wget -q https://raw.githubusercontent.com/argoproj/argo-cd/${1}/manifests/cluster-rbac/argocd-application-controller-clusterrole.yaml -O cluster-scope/base/clusterroles/argocd-application-controller/clusterrole.yaml

# ClusterroleBindings
echo "Updating Cluster ClusterRoleRolebindings.."
wget -q https://raw.githubusercontent.com/argoproj/argo-cd/${1}/manifests/cluster-rbac/argocd-application-controller-clusterrolebinding.yaml -O cluster-scope/base/clusterrolebindings/argocd-application-controller/clusterrolebinding.yaml
wget -q https://raw.githubusercontent.com/argoproj/argo-cd/${1}/manifests/cluster-rbac/argocd-server-clusterrolebinding.yaml -O cluster-scope/base/clusterrolebindings/argocd-server/clusterrolebinding.yaml

echo "Done!"
