## Thanos Access

[Thanos](https://github.com/thanos-io/thanos) is a set of components that can be composed into a highly available metric system with unlimited storage capacity, which can be added seamlessly on top of existing Prometheus deployments.

An instance of Thanos is available for use in Operate First.

The Query API/Console can be accessed at:

https://thanos-query-frontend-opf-observatorium.apps.smaug.na.operate-first.cloud/

To request access to the Thanos Query API, read the [following guide](request_thanos_access.md).

In this instance of Thanos, metric data will be stored as following:

| Resolution  | Duration    |
| ----------- | ----------- |
| Original/Raw| 7 days      |
| 5 min       | 30 days     |
| 1 hour      | Indefinite  |

Here the `Original/Raw` resolution means the resolution at which metrics were collected.

More information on how this retention of metric data can be found [here](https://github.com/thanos-io/thanos/blob/main/docs/components/compact.md#enforcing-retention-of-data).

*Note: the resolution and duration of the stored metric data might change in the future*

## Adding new metrics to Thanos
All of Thanos metric data is pushed in by the Openshift Monitoring Prometheus instances from various Operate First clusters.
