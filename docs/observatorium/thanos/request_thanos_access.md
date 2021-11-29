## Request Thanos Query API Access

To be able to query metrics directly from the Thanos Query API, you will need specific permissions.

Steps to follow:
1. Onboard your project/group to Operate First ([guide](https://github.com/operate-first/hitchhikers-guide/blob/main/pages/onboarding_project.ipynb)).
2. Once your group has been onboarded, add your group to [this list](https://github.com/operate-first/apps/blob/master/observatorium/overlays/moc/smaug/thanos/rolebindings/opf-observatorium-view.yaml#L10) and create a PR (Pull Request).
3. After your PR is reviewed/merged, you should have access to the Thanos Query Console and API.
