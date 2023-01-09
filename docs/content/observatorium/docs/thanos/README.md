# Thanos Access

[Thanos][1] is a set of components that can be composed into a highly available metric system with unlimited storage capacity, which can be added seamlessly on top of existing Prometheus deployments.

An instance of Thanos is available for use in Operate First.
## Requesting Thanos access

Thanos metrics can be accessed in two different ways:

1. Using the Grafana Console
2. Using the Thanos Console/Query-API

### Grafana Console access
The Operate First Grafana console can be accessed at: https://grafana.operate-first.cloud/

To request access to the Grafana Console, read the [following guide][2].

### Thanos Query API/Console access
The Thanos Query API/Console can be accessed at:

https://thanos-query-frontend-opf-observatorium.apps.smaug.na.operate-first.cloud/

To request access to the Thanos Query API, read the [following guide][3].

## Thanos Metrics Retention
In this instance of Thanos, metric data will be stored as following:

| Resolution  | Duration    |
| ----------- | ----------- |
| Original/Raw| 7 days      |
| 5 min       | 30 days     |
| 1 hour      | Indefinite  |

Here the `Original/Raw` resolution means the resolution at which metrics were collected.

More information on how this retention of metric data can be found [here][4].

*Note: the resolution and duration of the stored metric data might change in the future*

## Adding new metrics to Thanos
All of Thanos metric data is pushed in by the Openshift Monitoring Prometheus instances from various Operate First clusters.

[1]: https://github.com/thanos-io/thanos
[2]: request_grafana_access.md
[3]: request_thanos_access.md
[4]: https://github.com/thanos-io/thanos/blob/main/docs/components/compact.md#enforcing-retention-of-data
