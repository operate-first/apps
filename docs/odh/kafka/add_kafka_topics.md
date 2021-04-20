# Add Kafka Topics

To add Kafka topics, find your target environment create a new `KafkaTopic` resource within the `odh-manifests/kafka/overlays/topics` sub directory.

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

Save this file under `odh-manifests/kafka/overlays/topics/my-topic.yaml`.

Then add it to `odh-manifests/kafka/overlays/topics/kustomization.yaml` by running the following:

```bash
$ cd odh-manifests/kafka/overlays/topics
$ kustomize edit add resource my-topic.yaml
```

If you don't have `kustomize` then simply add this file manually.

The steps are identical for the other environments.
