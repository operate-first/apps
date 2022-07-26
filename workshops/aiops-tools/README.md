# AIOPS Tools Workshops

This directory contains the AIOPS Tools Workshop Stack.

Some beginner knowledge about [Kustomize][] and Openshift is required.

## How to use these manifests

All dependencies for the workshop can be found in the `base` directory.

Depending on what is available on the cluster, you can choose to deploy a select few, or all the `base` manifests.

Note that they are all required to make the workshop work.

For instance, for the deployment on the `smaug` cluster, various operators / groups / rbac were already available in the
cluster, so these weren't included in the `smaug` cluster overlay.

### Storage
S3 Storage is required, if you do not have an external s3 provider, a minio deployment is provided in the `base`
directory, adjust the credentials as needed via the secret provided. Note that you will need to navigate to the
minio deployment via the route and create a bucket yourself, this can be done via the Minio UI.

### Configuration
To configure your deployment you will need to create secrets and configmaps that are specific to your deployment and
cluster.

You will need to know your cluster's domain name, retrieve this by logging into your OCP cluster via `oc` cli and
execute the following:

```bash
INGRESS_DOMAIN=oc get ingresses.config/cluster -o jsonpath={.spec.domain}
```
This value will be used to construct routes in the configmaps/secrets.

** Dex **
Replace all values of ${ingress-domain} with `INGRESS_DOMAIN`
`workshops/aiops-tools/base/dex/configmaps/files/config.yaml`.

** ODH **
Go through all secrets in `workshops/aiops-tools/base/secrets` and replace values as needed. You will find comments
included within the secrets to guide you a long the way.

### External Secrets Operator (ESO)

In the `smaug` overlay you'll find `ExternalSecrets` these are secrets that reference confidential data in `Vault`.
This is not necessary for the workshop, you can just deploy the secrets manually as included in
`workshops/aiops-tools/base/secrets`. You will still need to deploy ESO operator however, as the manifests bundle
will still try to deploy some external secrets, they will just simply not be used.

### Resource Concerns

To tune the resources, simply patch all deployments as needed in the overlay. Run a full `kustomize build` with all
`base` folders. Look for `Deployment` and `StatefulSets` resources, patch them as needed. For ODH components, you will
need to tune the `kfdefs` resources, found in `workshops/aiops-tools/base/odh-kfdefs`.

[crbjh]: base/odh-operator/jupyterhub-clusterrolebinding.yaml
[Kustomize]: https://kustomize.io/
[kfp-tekton]: https://github.com/kubeflow/kfp-tekton/blob/master/guides/kfp_tekton_install.md#standalone-kubeflow-pipelines-with-tekton-backend-deployment
