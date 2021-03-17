# Add Kafka Topics

To add Kafka topics, find your target environment create a new `KafkaTopic` resource within the `odh/overlays/$ENV/$CLUSTER/kafka/overrides/kafka/overlay/topics` sub directory. `$ENV/$CLUSTER` corresponds to the environment and cluster you are adding the topic respectively. For example if you would like to add your `KafkaTopic` on `zero` cluster in the `MOC` environment then first create a topic like the one below:

Replace `my-topic` with a preferred name.

```yaml
# my-topic.yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: my-topic
  labels:
    strimzi.io/cluster: odh-message-bus
spec:
  partitions: 2
  replicas: 3
```

The label `strimzi.io/cluster` should have the value `odh-message-bus`. On MOC the recommended partition size is `2` and replica count is `3`. The replica count should be less than or equal to the number of Kafka brokers. On MOC `zero` cluster we have 3 brokers.

Pick a suitable name, ensure that it's unique in the `topics` folder.

Save this file under `odh/overlays/moc/zero/kafka/overrides/kafka/overlay/topics/my-topic.yaml`.

Then add it to `odh/overlays/moc/zero/kafka/overrides/kafka/overlay/topics/kustomization.yaml` by running the following:

```bash
$ cd odh/overlays/moc/kafka/overrides/kafka/overlay/topics/
$ kustomize edit add resource my-topic.yaml
```

If you don't have `kustomize` then simply add this file manually.

The steps are identical for the other environments.
