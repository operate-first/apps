# AIOPS Tools Workshops

Tools included in this folder:

* ODH Components
    * Jupyterhub
    * Trino
    * Superset
    * Seldon
* ODH Operator
* Dex
* Cloudbeaver
* KFP Tekton

Dependencies:
* ACME
* ODF (or an external s3 bucket)
  * Additional Jupyterhub [clusterrolebinding][crbjh]
* External Secrets Operator
* Vault
* Openshift Pipelines with [enable-custom-tasks][kfp-tekton] feature flags enabled.


> Note Vault / ESO dependency can be avoided by deploying secrets directly.

Manifests are bundled using [Kustomize][].

[crbjh]: base/odh-operator/jupyterhub-clusterrolebinding.yaml
[Kustomize]: https://kustomize.io/
[kfp-tekton]: https://github.com/kubeflow/kfp-tekton/blob/master/guides/kfp_tekton_install.md#standalone-kubeflow-pipelines-with-tekton-backend-deployment
