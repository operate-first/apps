# Deploying a development environment

## Prequisites
* An OCP 4.x Development cluster
* Must have cluster admin (not kube:admin)

## Instructions

Create the project `argocd` and `argocd-test`. The latter will be used
for deploying a dev application via ArgoCD.

```bash
oc new-project argocd-test
oc new-project argocd
```

### Deploy ArgoCD
```bash
git clone git@github.com:operate-first/apps.git
cd apps

# Deploy Cluster objects
kustomize build argocd/cluster-resources --enable-alpha-plugins | oc apply -f -

# Deploy Non Cluster objects
kustomize build argocd/overlays/dev --enable-alpha-plugins | oc apply -f -
```

## Configure Auth
Once deployed, there are some additional configurations, run this script:
```bash
scripts/argocd/configure_development.sh
```
The script needs to be run under a user with the cluster admin role, but not with `kube:admin`.

Feel free to look inside the script for detailed comments on what configurations are applied.

## Cleanup
Run the following commands to clean up your environment.

```
kustomize build argocd/overlays/dev --enable_alpha_plugins | oc delete -f -
kustomize build argocd/cluster-resources --enable_alpha_plugins | oc delete -f -
oc delete group dev-group
oc delete project argocd-test
oc delete project argocd
```

You may ignore the following error when removing secrets:

```
Error from server (NotFound): error when deleting "STDIN": secrets "argocd-dex-server-oauth-token" not found
Error from server (NotFound): error when deleting "STDIN": secrets "dev-cluster-spec" not found
```

## Connecting from the CLI

If you want to use the ArgoCD CLI, you can download it here: https://argoproj.github.io/argo-cd/cli_installation/.

To use the `argocd` tool you need to login first. To login into an ArgoCD running in an environment such as OperateFirst you would first figure the route. Assuming you are logged in your cluster with `oc` you can do:
```
ARGOCD_ROUTE=$(oc get route argocd-server -o jsonpath='{.spec.host}')
```

then login:

```
argocd --insecure --grpc-web login ${ARGOCD_ROUTE}:443 --sso
```

The login command will open a browser window to take you through the SSO process. Then you can proceed with using the tool:

```bash
argocd -h
```
