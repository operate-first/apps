# Enable monitoring for your service

We use [ODH](https://opendatahub.io/) Prometheus as part of our monitoring stack to scrape metrics.

To enable our Prometheus to monitor your services, you need to add the appropriate RBAC and service monitors.

You can choose to have one servicemonitor per service, or group all your services into one service monitor. The steps are similar in both cases.

### Pre-requisite:

You will need pre-requisite tools to follow along with this doc, please do one of the following:

- Install our [toolbox](https://github.com/operate-first/toolbox) to have the developer setup ready automatically for you.
- Install the tools manually. You'll need [kustomize](https://kustomize.io/), [sops](https://github.com/mozilla/sops) and [ksops](https://github.com/viaduct-ai/kustomize-sops).
- Ensure that each namespace the services belong to are listed [here](https://github.com/operate-first/apps/tree/master/cluster-scope/base/namespaces). If not then please file an issue [here](https://github.com/operate-first/support/issues/new?assignees=&labels=onboarding&template=onboarding_to_cluster.md&title=).

Please fork/clone the [operate-first/apps](https://github.com/operate-first/apps) repository. **During this whole setup, we'll be working within this repository.**

### Steps:

1. Run the following script to enable rbac for a namespace:

  ```
  bash scripts/enable-monitoring.sh NAMESPACE
  ```

  This script will add a line that contains the 'monitoring-rbac' component to the components field in the kustomization.yaml of the given namespace.

2. Add the service monitor filling out the details below accordingly:

  ```yaml
  ---
  apiVersion: monitoring.coreos.com/v1
  kind: ServiceMonitor
  metadata:
    name: ${SERVICE_MONITOR_NAME}
    labels:
      monitor-component: ${TEAM_OR_SERVICE_NAME}
  spec:
    endpoints:
      - targetPort: ${SERVICE_1_PORT}
      - targetPort: ${SERVICE_2_PORT}
      - targetPort: ...
    namespaceSelector:
      matchNames:
        - ${SERVICE_1_NAMESPACE}
        - ${SERVICE_2_NAMESPACE}
        - ...
    selector: {}
  ```

  Add this service monitor to `kfdefs/overlays/${ENV}/${CLUSTER}/opf-monitoring/servicemonitors`

3. Add the servicemonitor from (2) to `kfdefs/overlays/${ENV}/${CLUSTER}/opf-monitoring/servicemonitors/kustomization.yaml`
