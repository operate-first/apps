# kfp-tekton

The contents of this directory can be used to deploy Kubeflow pipelines with a Tekton backend.
They do not include the corresponding route.

## Pre-reqs

OpenShift Pipelines must already be installed on the cluster

You will also need to run the following command manually after OpenShift Pipelines is up and running.

```bash
kubectl patch cm feature-flags -n openshift-pipelines -p '{"data":{"enable-custom-tasks": "true", "enable-api-fields": "alpha"}}'
```
