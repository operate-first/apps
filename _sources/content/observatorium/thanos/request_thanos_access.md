# Thanos Query API

With Thanos Query access, you will be able to:
1. Access the [Thanos Query Frontend UI](https://thanos-query-frontend-opf-observatorium.apps.smaug.na.operate-first.cloud/)
2. Access the Thanos metrics programmatically using your OpenShift personal token ([instructions](thanos_programmatic_access.md))

### Steps to follow
To get the specific permissions needed query metrics directly from the Thanos Query API, please follow these steps:

1. Onboard your project/group to Operate First ([guide](https://github.com/operate-first/hitchhikers-guide/blob/main/pages/onboarding_project.ipynb))
2. Once your group has been onboarded, add your group to [this list](https://github.com/operate-first/apps/blob/master/observatorium/overlays/moc/smaug/thanos/rolebindings/opf-observatorium-view.yaml#L10) in a new line as: <br>
   ```yaml
    - kind: Group
      apiGroup: rbac.authorization.k8s.io
      name: MY_GROUP_NAME
   ```
   and create a PR (Pull Request). You can see an example Pull Request [here](https://github.com/operate-first/apps/pull/1378)
3. After your PR is reviewed/merged, you should have access to the Thanos Query Console and API
