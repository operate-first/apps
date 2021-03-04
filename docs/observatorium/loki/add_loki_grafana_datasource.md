# Add a Loki Data Source in OperateFirst Grafana

To be able to query logs for your [OrgID](https://grafana.com/docs/loki/latest/operations/multi-tenancy/) in Grafana, you need to add a new Loki data source
with the `'X-Scope-OrgID'` header set to your OrgID.

An example Data source template is shown below:

```yaml
# opf-example-loki-source.yaml
---
apiVersion: integreatly.org/v1alpha1
kind: GrafanaDataSource
metadata:
  name: loki-opf-example # update name here
spec:
  name: loki-opf-example # update name here
  datasources:
    - name: loki-opf-example # update name here
      type: loki
      access: proxy
      url: http://opf-observatorium-loki-query-frontend-http.opf-observatorium.svc.cluster.local:3100
      version: 1
      editable: false
      jsonData:
        httpHeaderName1: "X-Scope-OrgID"
      secureJsonData:
        httpHeaderValue1: "opf-example" # update OrgID here
```

In this template, all you need to do is update various resource names and
replace `opf-example` in `httpHeaderValue1` with a preferred OrgID. <br>
_Please note that you will have to use this OrgID to push logs into Loki,
otherwise your logs won't be visible in Grafana._

Pick a suitable name, ensure that it's unique in the [`observatorium/overlays/moc/grafana-data-sources`](../../../observatorium/overlays/moc/grafana-data-sources) folder.

Save this file under `observatorium/overlays/moc/zero/grafana-data-sources/opf-example-loki-source.yaml`.

Then add it to `observatorium/overlays/moc/zero/grafana-data-sources/kustomization.yaml` by running the following:

```bash
$ cd observatorium/overlays/moc/grafana-data-sources/
$ kustomize edit add resource opf-example-loki-source.yaml
```

The steps are identical for the other environments.
