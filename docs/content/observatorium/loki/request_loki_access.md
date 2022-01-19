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
curl -H "X-Scope-OrgID: opf-example" \
  -H "Authorization: Bearer MY_BEARER_TOKEN" \
  -G -s  "https://loki-frontend-opf-observatorium.apps.smaug.na.operate-first.cloud/loki/api/v1/query_range" \
  --data-urlencode 'query={app="my-app-1"}'
```

This command queries logs from Loki using `"app="my-app-1"` label as the
query.
_Notice that we had to provide the same OrgID "opf-example" to be able to query for the logs that we pushed in._

More Info on [/query_range][4]

[1]: https://github.com/operate-first/hitchhikers-guide/blob/main/pages/onboarding_project.ipynb
[2]: https://github.com/operate-first/apps/blob/master/observatorium/overlays/moc/smaug/thanos/rolebindings/opf-observatorium-view.yaml#L10
[3]: https://github.com/operate-first/apps/pull/1378
[4]: https://grafana.com/docs/loki/latest/api/#get-lokiapiv1query_range
