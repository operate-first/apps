# Grafana

With Grafana access, you will be able to:
1. Access the Grafana UI to visualize Operate First cluster metrics
2. View saved metric visualization dashboards in Operate First Grafana instance
3. Edit/Create new metric visualization dashboards in the Operate First Grafana instance

## Supported Roles
We support three different roles for accessing the Operate First Grafana instance:
* **Viewer**: User has view access to all the dashboards and metric/log datasources.
* **Editor**: In addition to *Viewer* permissions, user can edit/create new visualization dashboards.
* **Admin**: In addition to *Editor* permissions, user can manage Dashboards and Datasources.

More information about these roles is available [here](https://grafana.com/docs/grafana/latest/permissions/organization_roles/#compare-roles).


## Steps to follow
To get the specific permissions needed to get Grafana access, please follow these steps:

1. Onboard your project/group to Operate First ([guide](https://github.com/operate-first/hitchhikers-guide/blob/main/pages/onboarding_project.ipynb)).
2. Once your group has been onboarded, add your group and desired role to [this list](https://github.com/operate-first/apps/blob/master/grafana/overlays/moc/smaug/grafana-oauth.yaml#L29) in a new line as: <br>

   `contains(groups[*], 'MY_GROUP_NAME')        && 'MY_DESIRED_ROLE' ||` <br>

   and create a PR (Pull Request). You can see an example Pull Request [here](https://github.com/operate-first/apps/pull/1323).

3. After your PR is reviewed/merged, you should have access to the Thanos Query Console and API.
