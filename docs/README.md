# Documentation

Here you will find all markdown documentation that directly interact with the Apps repo.

Table of Contents:

- [About page](https://github.com/operate-first/apps/tree/master/docs/about)
- [ACM](https://github.com/operate-first/apps/tree/master/docs/acm)
- [ACME](https://github.com/operate-first/apps/tree/master/docs/acme)
- [ArgoCD and Gitops](https://github.com/operate-first/apps/tree/master/docs/argocd-gitops)
- [Cluster Scope and Privileged Resources](https://github.com/operate-first/apps/tree/master/docs/cluster-scope)
- [Development](https://github.com/operate-first/apps/tree/master/docs/development)
- [Grafana](https://github.com/operate-first/apps/tree/master/docs/grafana)
- [Kubeflow](https://github.com/operate-first/apps/tree/master/docs/kubeflow)
- [Observatorium](https://github.com/operate-first/apps/tree/master/docs/observatorium)
  - [Loki](https://github.com/operate-first/apps/tree/master/docs/observatorium/loki)
  - [Thanos](https://github.com/operate-first/apps/tree/master/docs/observatorium/thanos)
- [Openshift Container Storage](https://github.com/operate-first/apps/tree/master/docs/ocs)
- [Open Data Hub](https://github.com/operate-first/apps/tree/master/docs/odh)
  - [Jupyterhub](https://github.com/operate-first/apps/tree/master/docs/odh/jupyterhub)
  - [Kafka](https://github.com/operate-first/apps/tree/master/docs/odh/kafka)
  - [Superset](https://github.com/operate-first/apps/tree/master/docs/odh/superset)
  - [Trino](https://github.com/operate-first/apps/tree/master/docs/odh/trino)
- [User Workload Monitoring](https://github.com/operate-first/apps/tree/master/docs/uwm)



## Environments

If you would like to use one of the our clusters, please create an issue [here][3].

### [MOC][14]

The Operate First initiative currently manages two clusters within the MOC environment.

- [`Smaug` cluster][smaug] for all user workloads
- [`Infra` cluster][infra] for cluster management, housing ACM and ArgoCD

### [EMEA][23]

Operate First deploys the following cluster within the EMEA region.

- [`Rick` cluster][rick] for experimental user workloads

### [OS-Climate][24]

OS-Climate (OSC) cluster provides a unified, open Multimodal Data Processing platform used by OS-Climate members to collect, normalize and integrate climate and ESG data from public and private sources.

## Managed Services

Operate First manages various applications and services in the environments listed above.

* [Grafana][6]

    * We use Grafana for monitoring and dashboards
    * To request access to Grafana, please file an issue [here][7]

* [Open Data Hub][15]
    * We manage a deployment of Open Data Hub (ODH) on the Smaug cluster and OSC cluster
    * [Read more][odh1] about our deployment of ODH and access our [dashboard][odh2]

* [ArgoCD][17]
    * We manage a multi-tenant deployment of ArgoCD on the MOC Infra cluster
    * Anyone can be onboarded to this ArgoCD instance and use it to deploy to any cluster managed by Operate First
        * Before being onboarded to ArgoCD, you must be onboarded to the OCP cluster you wish to deploy your applications on
        * Request access to an OCP cluster by filing an issue [here][4] and ArgoCD by filing an issue [here][5]
    * Console: https://argocd.operate-first.cloud

* [Observatorium][18]

    > Note: Links are currently outdated as Observatorium is being migrated to Smaug cluster. We will update this document with the new routes once the migration is complete.
    * We have an instance of Observatorium currently being used to provision Thanos and Loki
    * Thanos enables long term storage for Prometheus (deployed by ODH)
        * Anyone can enable their applications deployed on the Smaug cluster to be monitored by this Prometheus instance
        * To do so, follow the instructions [here][8] and make a pull request against this repo
    * Loki is used to query logs; click [here][9] to learn more about sending or retrieving logs using Loki
    * Thanos: http://thanos-query-frontend-opf-observatorium.apps.zero.massopen.cloud

* [OpenShift Data Foundation][20]
    * We deploy the OpenShift Data Foundation (ODF) operator on the Smaug cluster
    * ODF provides both persistent volumes and S3 compatible object storage via [Rook][12] Operator
    * Users can deploy their own S3 buckets via ObjectBucketClaims. Visit [this page][13] for more information and request an S3 bucket by filing an issue [here][10].

* [Dex OIDC Provider][21]

    * We manage an instance of Dex on the Smaug cluster to provide authentication for some of our services
    * Our Dex instance can also be used to drive authentication for other users. While documents are not yet available for this, experienced users can find the configurations [here][11]

[3]: https://github.com/operate-first/support/issues/new?assignees=&labels=onboarding&template=onboarding_to_cluster.yaml&title=
[4]: https://github.com/operate-first/support/issues/new?assignees=&labels=onboarding&template=onboarding_to_cluster.yaml&title=
[5]: https://github.com/operate-first/support/issues/new?assignees=&labels=onboarding&template=onboarding_argocd.yaml&title=
[6]: https://grafana.com/
[7]: https://github.com/operate-first/support/issues
[8]: https://github.com/operate-first/support/blob/main/docs/add_service_monitoring.md
[9]: https://www.operate-first.cloud/users/apps/docs/observatorium/loki/README.md
[10]: https://github.com/operate-first/support/issues/new?assignees=first-operator&labels=kind%2Fonboarding%2Carea%2Fbucket&template=ceph_bucket_request.yaml&title=BUCKET%3A+%3Cname%3E
[11]: https://github.com/operate-first/apps/tree/master/dex
[12]: https://rook.io/
[13]: https://www.operate-first.cloud/users/support/docs/claiming_object_store.md
[14]: https://massopen.cloud/
[15]: https://opendatahub.io/
[17]: https://argoproj.github.io/argo-cd/
[18]: https://github.com/observatorium
[20]: https://cloud.redhat.com/products/container-storage/?extIdCarryOver=true&sc_cid=701f2000001Css5AAC
[21]: https://github.com/dexidp/dex
[23]: https://www.hetzner.com/
[24]: https://github.com/os-climate/os_c_data_commons

[smaug]: https://console-openshift-console.apps.smaug.na.operate-first.cloud/
[infra]: https://console-openshift-console.apps.moc-infra.massopen.cloud/
[rick]: https://console-openshift-console.apps.rick.emea.operate-first.cloud/

[odh1]: https://github.com/operate-first/apps/tree/master/docs/odh
[odh2]: https://odh.operate-first.cloud/
