set -o allexport -o pipefail -ex

# Pre-condition:
# - Create the config file at location ${PAYLOAD_PATH}
# - Clone the github.com/operate-first/apps repo at location ${WORKING_DIR}
# - Working branch should be clean, checked out of upstream default branch.
# - Set Environment variables: ORG_NAME (=operate-first), SOURCE_REPO (=support), ISSUE_NUMBER

CONFIG=${PAYLOAD_PATH}
REPO=${WORKING_DIR}/apps

# Unpack Config file, we will need these environment variables for the remainder of the steps
PROJECT=$(yq e .project-name ${CONFIG})
ENVIRONMENT=$(yq e '.environment[0] | downcase' ${CONFIG})
CLUSTER=$(yq e '.cluster[0] | downcase' ${CONFIG})
NAMESPACE=$(yq e '.project-name | downcase' ${CONFIG})
REQUESTER=$(yq e '.project-owner' ${CONFIG})
DISPLAY_NAME=$(yq e '.project-name' ${CONFIG})
PROJECT_OWNER=$(yq e '.project-owner' ${CONFIG})
ONBOARDING_ISSUE=https://github.com/${ORG_NAME}/${SOURCE_REPO}/issues/${ISSUE_NUMBER}
DOCS=$(yq e '.project-docs-link' ${CONFIG})
GROUP=$(yq e '.team-name' ${CONFIG})
USERS=$(yq '.users | split(",") | map(trim)' -o json -I=0 ${CONFIG})
QUOTA=$(yq e '.quota[0] | downcase' ${CONFIG})

# Create OCP Group for team being onboarded

GROUP_PATH="${REPO}/cluster-scope/base/user.openshift.io/groups/${GROUP}";
mkdir ${GROUP_PATH}
jsonnet --ext-str GROUP --ext-code USERS scripts/jsonnet/group.jsonnet | yq -P > ${GROUP_PATH}/group.yaml
cd ${GROUP_PATH}
kustomize init ${GROUP_PATH}
kustomize edit add resource group.yaml

# Create namespace for team being onboarded

cd ${REPO}
NAMESPACE_PATH="${REPO}/cluster-scope/base/core/namespaces/${NAMESPACE}/";
mkdir ${NAMESPACE_PATH}
jsonnet --ext-str NAMESPACE \
  --ext-str REQUESTER \
  --ext-str DISPLAY_NAME \
  --ext-str PROJECT_OWNER \
  --ext-str ONBOARDING_ISSUE \
  --ext-str DOCS \
  scripts/jsonnet/namespace.jsonnet | yq -P > ${NAMESPACE_PATH}/namespace.yaml
cd ${NAMESPACE_PATH}
kustomize init ${NAMESPACE_PATH}
kustomize edit add resource namespace.yaml
kustomize edit set namespace ${NAMESPACE}
kustomize edit add component ../../../../components/limitranges/default
kustomize edit add component ../../../../components/resourcequotas/${QUOTA}

# "Give the team being onboarded access to the Namespace via OCP rbac"

cd ${REPO}
RBAC_PATH="${REPO}/cluster-scope/components/project-admin-rolebindings/${GROUP}"
mkdir ${RBAC_PATH}
jsonnet --ext-str GROUP --ext-code USERS scripts/jsonnet/rbac.jsonnet | yq -P > ${RBAC_PATH}/rbac.yaml
cd ${RBAC_PATH}
kustomize init ${RBAC_PATH}
kustomize edit add resource rbac.yaml

# Add rbac to the namespace being onboarded.

cd ${NAMESPACE_PATH}
kustomize edit add resource ../../../../components/project-admin-rolebindings/${GROUP}

# Up until now we have created resources in the base directory
# We now need to include these resources onto the target cluster for which this team needs to be onboarded.
# We do this by adding these newly created resources to the target cluster's overlay directory.

cd ${REPO}/cluster-scope/overlays/prod/${ENVIRONMENT}/${CLUSTER}
kustomize edit add resource ../../../../base/core/namespaces/${NAMESPACE}

# We keep the resources list in kustomization.yaml sorted for human readability
yq -i '.resources |= sort' kustomization.yaml

cd ${REPO}/cluster-scope/overlays/prod/common
kustomize edit add resource ../../../base/user.openshift.io/groups/${GROUP}

# Same as before, sort the resources field
yq -i '.resources |= sort' kustomization.yaml

# Commit changes
cd ${REPO}
git add cluster-scope
git commit -m "Onboarding team ${GROUP}."

set -o allexport
