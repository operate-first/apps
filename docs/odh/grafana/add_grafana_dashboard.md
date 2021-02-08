# Add a grafana dashboard to OperateFirst Grafana

To be able to include your dashboards in Grafana, you will need to add a `GrafanaDashboard` custom resource. This custom resource is defined as a yaml file that can remotely reference the dashboard contents from a specified URL and falls back to an embedded json only if the URL can not be resolved.

An example `grafana-dashboard-example.yaml` template is shown below:

```yaml
---
apiVersion: integreatly.org/v1alpha1
kind: GrafanaDashboard
metadata:
  name: grafana-dashboard-from-url
  labels:
    app: grafana
spec:
  name: grafana-dashboard-from-url.json
  url: https://raw.githubusercontent.com/integr8ly/grafana-operator/master/deploy/examples/remote/grafana-dashboard.json
```

In this template, all you need to do is update:

1. `metadata.name` - the dashboard name
2. `spec.url` - the URL pointing to the location of your dashboard JSON file

Pick a suitable `metadata.name`, ensure that its unique in the [`odh/base/monitoring/overrides/grafana-operator/overlays/dashboards`](https://github.com/operate-first/apps/tree/master/odh/base/monitoring/overrides/grafana-operator/overlays/dashboards) folder.

Save this file under `odh/base/monitoring/overrides/grafana-operator/overlays/dashboards/grafana-dashboard-example.yaml`.

Then add it to `odh/base/monitoring/overrides/grafana-operator/overlays/dashboards/kustomization.yaml` by running the following:

````bash
$ cd odh/base/monitoring/overrides/grafana-operator/overlays/dashboards/
$ kustomize edit add resource grafana-dashboard-example.yaml
````
