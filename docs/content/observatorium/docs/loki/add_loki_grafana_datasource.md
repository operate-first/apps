# Add a Loki Data Source in OperateFirst Grafana

To be able to query logs for your [OrgID][1] in Grafana, you need to add a new Loki data source
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
replace `opf-example` in `httpHeaderValue1` with a preferred OrgID.
_Please note that you will have to use this OrgID to push logs into Loki,
otherwise your logs won't be visible in Grafana._

Pick a suitable name, and add it our `smaug` `grafana` configurations [here][2]. Ensure that the name is unique amongst the `GrafanaDataSource`.

Also add this datasource file to the main `kustomization.yaml` by running the following:

```bash
$ cd grafana/overlays/moc/smaug/kustomization.yaml
$ kustomize edit add resource opf-example-loki-source.yaml
```

[1]: https://grafana.com/docs/loki/latest/operations/multi-tenancy/
[2]: https://github.com/operate-first/apps/tree/master/grafana/overlays/moc/smaug
