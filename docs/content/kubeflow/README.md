# Kubeflow

> Note: Currently our Kubeflow deployments are no longer active, see [this discussion][4] for details.

The Operate First managed Kubeflow deployment on the MOC cluster is available for the public to experience.

The Kubeflow dashboard can be accessed via our ISTIO ingress gateway link: http://istio-ingressgateway-istio-system.apps.zero.massopen.cloud/

Below is a list of all the components deployed, and relevant links to their UI and consoles.

## Components List

### [Kubeflow Dashboard][1]

Link to UI: http://istio-ingressgateway-istio-system.apps.zero.massopen.cloud/

### [Kubeflow Pipelines][2]

Link to UI: http://istio-ingressgateway-istio-system.apps.zero.massopen.cloud/pipeline/

### [Tekton Pipelines][3]

Link to UI: http://tekton-dashboard-tekton-pipelines.apps.zero.massopen.cloud/

[1]: https://www.kubeflow.org/docs/components/central-dash/overview/
[2]: https://www.kubeflow.org/docs/components/pipelines/
[3]: https://github.com/tektoncd/pipeline
[4]: https://github.com/operate-first/support/issues/435
