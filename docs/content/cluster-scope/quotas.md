# Resource Quota Tiers

When requesting a namespace, you can choose from 1 of 4 tier options for your resource quota:

|         | CPU Cores | Memory | Storage |
|---------|-----------|--------|---------|
| X-Small |    500m   |   2Gi  |   10Gi  |
| Small   |     1     |   4Gi  |   20Gi  |
| Medium  |     2     |   8Gi  |   40Gi  |
| Large   |     4     |  16Gi  |   80Gi  |

To understand the difference between cpu and memory limits/requests, please refer to [this][k8s-doc].

# Requesting custom quotas

Please make an issue in this repo if your project has requirements that are not met by the default quotas.

[k8s-doc]: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits
