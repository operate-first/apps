set -o allexport -o pipefail -ex

# Pre-condition:
# - Create the config file at location ${PAYLOAD_PATH}
# - Clone the github.com/operate-first/apps repo at location ${WORKING_DIR}
# - Working branch should be clean, checked out of upstream default branch.

CONFIG=${PAYLOAD_PATH}
REPO=${WORKING_DIR}/apps

# Unpack Config file, we will need these environment variables for the remainder of the steps
PROJECT=$(yq e .project-name ${CONFIG})
CLUSTER=$(yq e '.cluster[0] | downcase' ${CONFIG})
NAMESPACE=$(yq e '.project-name | downcase' ${CONFIG})
GROUP=$(yq e '.team-name' ${CONFIG})

# Remove OCP Group for team being onboarded
GROUP_PATH="${REPO}/cluster-scope/base/user.openshift.io/groups/${GROUP}";
rm ${GROUP_PATH} -rf

# Remove namespace for team being onboarded
NAMESPACE_PATH="${REPO}/cluster-scope/base/core/namespaces/${NAMESPACE}/";
rm ${NAMESPACE_PATH} -rf

# "Give the team being onboarded access to the Namespace via OCP rbac"

RBAC_PATH="${REPO}/cluster-scope/components/project-admin-rolebindings/${GROUP}/"
rm ${RBAC_PATH} -rf

# Remove from cluster
cd ${REPO}/cluster-scope/overlays/prod/common
kustomize edit remove resource ../../../base/user.openshift.io/groups/${GROUP}
yq -i '.resources |= sort' kustomization.yaml

cd ${REPO}/cluster-scope/overlays/prod/${CLUSTER}
kustomize edit remove resource ../../../../base/core/namespaces/${NAMESPACE}
yq -i '.resources |= sort' kustomization.yaml

# Commit changes
cd ${REPO}
git add cluster-scope
git commit -m "Off-boarding team ${GROUP}."

set -o allexport
