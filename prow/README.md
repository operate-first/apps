# PROW

This is a standalone ArgoCD Application for PROW. It is meant to be deployed into a separate OpenShift Project, therefore it is not references from the `kustomization.yaml` file at the root directory of this repository.


## Validation/Compliance

`kustomize build --enable_alpha_plugins overlays/thoth-station | conftest test --policy ../policy -`

## How to know on which environment are tests running on Prow?

The images used to run tests using Prow are listed in the [thoth-station/thoth-ops-infra](https://github.com/thoth-station/thoth-ops-infra) repository.
For each repository where Prow is configured, the tests run by Prow and the base container image they use are available in the `.prow.yaml` file.
