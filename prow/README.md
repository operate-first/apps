# PROW

![Argocd](https://argocd.operate-first.cloud/api/badge?name=ci-prow-prod-smaug&revision=true)


This is a standalone ArgoCD Application for PROW. It is meant to be deployed into a separate OpenShift Project, therefore it is not references from the `kustomization.yaml` file at the root directory of this repository.


## Validation/Compliance

Kustomize is used for deployment of prow.
`kustomize build --enable_alpha_plugins overlays/smaug | conftest test --policy ../policy -`

## Where can the additional prow images be found?

The images used to run tests using Prow are listed in the [thoth-station/thoth-ops-infra](https://github.com/thoth-station/thoth-ops-infra) repository.
For each repository where Prow is configured, the tests are run by Prow and the base container image they use are available in the `.prow.yaml` file.

## How to update the images of prow components?

The images used in prow component deployment uses imagestreams, there is [script](./update-imagestreams.py) in the directory to update the imagestreams.

- Grab the tag from prow images with the following command:
    `curl -s https://raw.githubusercontent.com/kubernetes/test-infra/master/config/prow/cluster/deck_deployment.yaml | grep gcr.io/k8s-prow/`
- Execute the python script inside the directory prow with tag as an argument.
    `python update-imagestreams.py v20220812-9414716697`

More information on the prow component images:
- https://console.cloud.google.com/gcr/images/k8s-prow/GLOBAL?pli=1
- https://github.com/kubernetes/test-infra/tree/master/config/prow/cluster
- https://github.com/kubernetes/test-infra/blob/master/prow/cmd/README.md


**NOTE**:
As noted in the [release note](https://github.com/kubernetes/test-infra/blob/master/prow/ANNOUNCEMENTS.md#breaking-changes) of prow, as per feb 22,2022. The utility images such as clonerefs, init-upload, sidecars and enrtypoint.
Testing is required before these image are upgraded, as it impacts presubmit jobs.
