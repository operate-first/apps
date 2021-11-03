# Open Data Hub (ODH) on MOC Zero

The Operate First managed ODH deployment on the MOC cluster is available for the public to experience.

The ODH dashboard can be found at: https://odh.operate-first.cloud/

[![ODh Dashboard](../assets/images/odh-dashboard.png)][1]

Below is a list of all the components deployed, and relevant links to their UI.

## Components List

### [Argo Workflows][3]

UI: http://argo-server-opf-argo.apps.zero.massopen.cloud/

Monitoring: [Link][20]

> Note: Login via OCP is [WIP][16]

### [Grafana][4]

UI: https://grafana-opf-monitoring.apps.zero.massopen.cloud

Submit an issue [here][2] for access.

### [JupyterHub][6]

UI: https://jupyterhub.datahub.redhat.com/hub/

Monitoring: [Link][21]

You will need to login using the OCP SSO (any Gmail account is sufficient).

Visit the JupyterHub section at https://www.operate-first.cloud/users/support/ to learn more aobut how to add your own image, and try out different available demos.

### [Kafka][7]

Kafka broker URL: http://kafdrop-route-opf-kafka.apps.zero.massopen.cloud/

Monitoring: [Link][22]

Please visit this [link][19] to get access and request topics.

### [ODH Dashboard][8]

UI: https://odh.operate-first.cloud/

### [Prometheus][9]

Prometheus UI: http://prometheus-portal-opf-monitoring.apps.zero.massopen.cloud/

AlertManager UI: http://alert-manager-opf-monitoring.apps.zero.massopen.cloud/

You can enable your applications running on the Zero cluster to be monitored by this Prometheus, see [here][23] for details on how to do this.

### [Trino][11]

UI: https://trino-secure-opf-trino.apps.zero.massopen.cloud/

### [Superset][12]

UI: https://superset-secure-opf-superset.apps.zero.massopen.cloud

Submit an issue [here][2] for access.

#### Components not deployed
The following components are currently not deployed:

- AI-Library
- [Airflow][14]
- [Seldon][15]

If you require any of these components please submit a request [here][2].

[1]: https://odh.operate-first.cloud/
[2]: https://github.com/operate-first/odh-moc-support/issues
[3]: https://argoproj.github.io/projects/argo/
[4]: https://grafana.com/
[5]: https://gethue.com/
[6]: https://jupyter.org/hub
[7]: https://kafka.apache.org/
[8]: https://github.com/opendatahub-io/odh-dashboard
[9]: https://prometheus.io/
[10]: https://spark.apache.org/
[11]: https://trino.io/
[12]: https://superset.apache.org/
[13]: https://www.seldon.io/
[14]: https://airflow.apache.org/
[15]: https://github.com/operate-first/odh/issues/47
[16]: https://github.com/operate-first/odh/issues/39
[17]: https://github.com/operate-first/odh/issues/37
[18]: https://github.com/operate-first/odh/issues/48
[19]: https://www.operate-first.cloud/users/apps/docs/odh/kafka/README.md
[20]: https://grafana-route-opf-monitoring.apps.zero.massopen.cloud/d/qIsQ7aHGk/argo-workflow?orgId=1
[21]: https://grafana-route-opf-monitoring.apps.zero.massopen.cloud/d/BfSK2f1Mz/jupyterhub-sli-slo?orgId=1
[22]: https://grafana-route-opf-monitoring.apps.zero.massopen.cloud/d/80de0e219205a33a2d87820f1ce335b6805ddbfc/kafka-overview?orgId=1
[23]: https://github.com/operate-first/support/blob/main/docs/add_service_monitoring.md
[24]: https://www.operate-first.cloud/users/data-science-workflows/docs/create_and_deploy_jh_image.md
