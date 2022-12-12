# Thanos Query API

With Thanos Query access, you will be able to:
1. Access the [Thanos Query Frontend UI][1]
2. Access the Thanos metrics programmatically using your OpenShift personal token ([instructions][2])

## Steps to follow
To get the specific permissions needed query metrics directly from the Thanos Query API, please follow these steps:

1. Onboard your project/group to Operate First ([guide][3])
2. Once your group has been onboarded, add your group to [this list][4] in a new line as: <br>
   ```yaml
    - kind: Group
      apiGroup: rbac.authorization.k8s.io
      name: MY_GROUP_NAME
   ```
   and create a PR (Pull Request). You can see an example Pull Request [here][5]
3. After your PR is reviewed/merged, you should have access to the Thanos Query Console and API

[1]: https://thanos-query-frontend-opf-observatorium.apps.smaug.na.operate-first.cloud/
[2]: thanos_programmatic_access.md
[3]: https://github.com/operate-first/hitchhikers-guide/blob/main/pages/onboarding_project.ipynb
[4]: https://github.com/operate-first/apps/blob/master/observatorium/overlays/moc/smaug/thanos/rolebindings/opf-observatorium-view.yaml#L10
[5]: https://github.com/operate-first/apps/pull/1378
