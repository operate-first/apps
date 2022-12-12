# Add Kafka Users

We manage access to Kafka Topics in our Kafka instance using the [`KafkaUser` resource][1].

To add a new `KafkaUser`, create a new `KafkaUser` resource within the `kafka/overlays/smaug/users` sub directory.

Replace `my-user` with a preferred name.

```yaml
# my-user.yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaUser
metadata:
  name: my-user
spec:
  authentication:
    type: tls
  authorization:
    acls:
      # Using a topic name prefix
      - host: '*'
        operation: All
        resource:
          # this will give user access to all topics with the "my-topic." prefix
          name: my-topic.
          patternType: prefix
          type: topic
        type: allow
      # Using a topic name literal
      - host: '*'
        operation: All
        resource:
          # this will give user access to only the topic named "my-topic.1"
          name: my-topic.1
          patternType: literal
          type: topic
        type: allow
      # Only clients using group ids with "my-group." prefix will have access to the topics
      - host: '*'
        operation: All
        resource:
          name: my-group.
          patternType: prefix
          type: group
        type: allow
    type: simple
```
You need a group id that has access to your topic to be able to consume from it, so make sure that you have at least one group with access to your topics.
To learn more about how consumer groups work [here][2] is a tutorial.

The label `strimzi.io/cluster` should have the value `odh-message-bus`.

Pick a suitable name, ensure that it's unique in the `users` folder.

Save this file under `kafka/overlays/smaug/users/my-users.yaml`.

Then add it to `kafka/overlays/smaug/users/kustomization.yaml` by running the following:

```bash
$ cd kafka/overlays/smaug/users
$ kustomize edit add resource my-user.yaml
```

If you don't have `kustomize` then simply add this file manually.

[1]: https://strimzi.io/docs/operators/0.22.1/using.html#type-KafkaUser-reference
[2]: https://www.tutorialspoint.com/apache_kafka/apache_kafka_consumer_group_example.htm
