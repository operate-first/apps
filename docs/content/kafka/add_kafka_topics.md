# Add Kafka Topics

To add Kafka topics, create a new `KafkaTopic` resource within the `kafka/overlays/smaug/topics` sub directory.

Replace `my-topic` with a preferred name.

```yaml
# my-topic.yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: my-topic
  labels:
    strimzi.io/cluster: odh-message-bus
spec:
  partitions: 2
  replicas: 3
  config:
    # message retention period is 6 hours
    retention.ms: 21600000
```

The label `strimzi.io/cluster` should have the value `odh-message-bus`. On MOC the recommended partition size is `2` and replica count is `3`. The replica count should be less than or equal to the number of Kafka brokers. On MOC `smaug` cluster we have 3 brokers.

Pick a suitable name, ensure that it's unique in the `topics` folder.

Save this file under `kafka/overlays/smaug/my-topic.yaml`.

Then add it to `kafka/overlays/smaug/kustomization.yaml` by running the following:

```bash
$ cd kafka/overlays/smaug/topics
$ kustomize edit add resource my-topic.yaml
```

If you don't have `kustomize` then simply add this file manually.
