# Loki Query API

With Thanos Query access, you will be able to:
1. Access the Loki logs programmatically using your OpenShift personal token

## Steps to follow
To get the specific permissions needed to query logs directly from the Loki Query API, please follow these steps:

1. Onboard your project/group to Operate First ([guide][1])
2. Once your group has been onboarded, add your group to [this list][2] in a new line as: <br>
   ```yaml
    - kind: Group
      apiGroup: rbac.authorization.k8s.io
      name: MY_GROUP_NAME
   ```
   and create a PR (Pull Request). You can see an example Pull Request [here][3]
3. After your PR is reviewed/merged, you should have access to the Thanos Query Console and API

#### Example: Loki Query API

- url: https://loki-frontend-opf-observatorium.apps.smaug.na.operate-first.cloud

This is the endpoint that can be used to query logs from Loki.

Example:

```bash
MY_BEARER_TOKEN="sha256~1A...DW-id...NE-...lWM"
curl -H "X-Scope-OrgID: cluster-infra-logs" \
  -H "Authorization: Bearer $MY_BEARER_TOKEN" \
  -G -s  "https://loki-frontend-opf-observatorium.apps.smaug.na.operate-first.cloud/loki/api/v1/query_range" \
  --data-urlencode 'query={cluster_log_level="infra-logs"}'
```

This command queries logs from Loki using `{cluster_log_level="infra-logs"}` label as the
query. Notice that we had to provide the same OrgID "cluster-infra-logs" to be able to query for the logs that we pushed in.

While querying Loki for logs, you will need to have a header `'X-Scope-OrgID'` set in your requests.
This header is used to identify tenants in a [multi tenancy setup][7].
To see which OrgID values are available look into the configured [Loki Grafana Datasources][5]

More Info on [/query_range][4]

Some documentation about the Loki Query API is available [here][6].

You also need a [BEARER_TOKEN][../thanos/thanos_programmatic_access.md]

[1]: https://github.com/operate-first/hitchhikers-guide/blob/main/pages/onboarding_project.ipynb
[2]: https://github.com/operate-first/apps/blob/master/observatorium/overlays/moc/smaug/thanos/rolebindings/opf-observatorium-view.yaml#L10
[3]: https://github.com/operate-first/apps/pull/1378
[4]: https://grafana.com/docs/loki/latest/api/#get-lokiapiv1query_range
[5]: https://github.com/operate-first/apps/blob/master/grafana/overlays/moc/smaug/datasources/cluster-logs.yaml
[6]: https://grafana.com/docs/loki/latest/api/
[7]: https://grafana.com/docs/loki/latest/operations/multi-tenancy/
