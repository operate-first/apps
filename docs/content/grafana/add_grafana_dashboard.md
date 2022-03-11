# Add a Grafana dashboard to OperateFirst Grafana

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
  customFolderName: ${DASHBOARD_FOLDER} # Pi
  name: grafana-dashboard-from-url.json
  url: https://raw.githubusercontent.com/integr8ly/grafana-operator/master/deploy/examples/remote/grafana-dashboard.json
```

In this template, all you need to do is update:

1. `metadata.name` - the dashboard name
2. `spec.url` - the URL pointing to the location of your dashboard JSON file

Pick a suitable `metadata.name`, ensure that its unique in the [`grafana/overlays/moc/smaug/dashboards`][1] folder.

Save this file under `grafana/overlays/moc/smaug/dashboards/${DASHBOARD_FOLDER}/grafana-dashboard-example.yaml`.

Make sure to create a kustomization inside your '${DASHBOARD_FOLDER}'

```bash
$ cd ${DASHBOARD_FOLDER}
$ kustomize create --autodetect
```

Then add it to `grafana/overlays/moc/smaug/dashboards/kustomization.yaml` by running the following:

```bash
$ cd grafana/overlays/moc/smaug/dashboards
$ kustomize edit add resource ${DASHBOARD_FOLDER}
```

### Backing Up Your Dashboard:
Grafana is redeployed frequently, such as during an automatic operator update or when a new dashboard is added via a pull request. Please make sure to backup any dashboards you have created through the Grafana UI.

To export your dashboard click the share icon ![](img/share-icon.png) at the top dashboard menu. Click the "Export" tab and you can now save a JSON file of your dashboard.

To import your dashboard click the "+" icon in the side menu, and then click "Import." There you can either import via JSON file, dashboard url, or via panel json. For more details on how to import/export see [the Grafana documentation](https://grafana.com/docs/grafana/latest/dashboards/export-import/).

[1]: https://github.com/operate-first/apps/tree/master/grafana/overlays/moc/smaug/dashboards
