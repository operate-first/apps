# Kafka Runbook

## Key Locations

| Env                                 | Namespace                                                 | GitHub Repo                                  |
|-------------------------------------|-----------------------------------------------------------|----------------------------------------------|
| MOC-Smaug Prod                      | [opf-kafka][1]                                            | - [kfdef app][2]<br />- [kafka resources][3] |

## Contact for Additional Help

* Strimzi Team - https://slack.cncf.io/
* Internal Data Hub Team - data-hub@redhat.com

## Dashboards

Links to the monitoring dashboards for this service.

| Dashboard Description | Dashboard URL      |
|-----------------------|--------------------|
| Kafka Overview        | N/A - [pending][4] |

Some items to take note of:

| Metric                      | Purpose                                                               | Desired Value                                                                             | Action if out of desired range                                                                     |
|-----------------------------|-----------------------------------------------------------------------|-------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| Brokers online              | The number of kafka brokers active in the cluster                     | This should match whatever number is configured in Git for the cluster size (currently 3) | Check kafka broker pods for restarts or pod logs for signs of error                                |
| Under replicated partitions | The number of kafka partitions that don't have replicas fully in sync | 0                                                                                         | Check kafka broker pod logs for signs of errors                                                    |
| Offline partitions count    | The number of kafka partitions that don't have any replicas online    | 0                                                                                         | Check for offline Kafka brokers. Check for kafka topics that don't have replication fully enabled. |

## Prerequisites

You will need cluster admin to access `openshift-operators` and need to be in the `operate-first` ocp group to access `opf-kafka` namespace.

## Deployment

Our Kafka instance is managed by the Open Data Hub operator.

## Kafka Topology

There are several different types of pods associated with our Kafka deployment.
They are as follows:

| Pods                          | Description                                                                                                                                                              |
|-------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Strimzi cluster operator][5] | This is the main Strimzi operator pod. It orchestrates all other pods and resides in the `openshift-operators` namespace.                                                |
| Zookeeper                     | Zookeper performs controller election, cluster membership and maintain a list of all topics and configurations for the kafka brokers.                                    |
| Kafka Brokers                 | Kafka brokers handle and store the topic log partitions and services the consumers and producers. These are deployed and managed by the Strimzi Operator.                |
| Kafka Connect                 | Kafka connect utilizes various connectors to connect the Kafka cluster to a variety of data sources and streams. These are deployed and managed by the Strimzi Operator. |

## Kafka Admin Scripts

Kafka comes pre bundled with a number of administrative scripts. These are
located on each of the Kafka broker pods in the `/opt/kafka/bin/`
directory. Some particularly useful scrips are as follows:

| Script                         | Use                                                                                  |
|--------------------------------|--------------------------------------------------------------------------------------|
| `kafka-topics.sh`              | View topics in the cluster, information about a specific topic, create a topic, etc. |
| `kafka-consumer-groups.sh`     | View statistics about a consumer group                                               |
| `kafka-console-producer.sh`    | Manually produce messages onto a topic                                               |
| `kafka-console-consumer.sh`    | Manually consume messages from a topic                                               |
| `kafka-reassign-partitions.sh` | Manually reassign partitions of a topic to a different broker node                   |
| `kafka-log-dirs.sh`            | Query log directory usage on the specified brokers                                   |

## Smoke Test

Some steps to take to ensure that the Kafka cluster is performing as expected
are as follows. These all require rsh'ing into a Kafka broker pod and
running the above admin scripts.

### Ensure kafka topics exist

```
/opt/kafka/bin/kafka-topics.sh --zookeeper localhost --list
```

If topics are not listed, something is wrong.

### Ensure kafka consumer groups

```
/opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server three-kafka-bootstrap:9092 --list
```

If no consumer groups are listed, something is wrong.

### Check consumer group lag

```
/opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server three-kafka-bootstrap:9092 --describe --group $NAME
```

You will need to replace $NAME with the name of a particular consumer group. If the
group lag is large and growing, something may be wrong.

## Common Debugging Steps

### Topic partition reassignment

From time to time we may need to manually reassign Kafka topic partitions.
This may be done if disk space consumption across the Kafka brokers becomes
unbalanced. In theory this should not happen since all of our Kafka topics
are replicated across all brokers. To perform a rebalance, you first need
to create a `topics-to-move.json` file listing which topics to move. The format
of the file should be as follows:

```
{
  "topics": [
    {"topic": "dynamic-exd-meteor"},
    {"topic": "dh-test"}
  ],
  "version":1
}
```

You can then auto-generate a recommended balanced allocation of the topics
listed by running the following command:

```
/opt/kafka/bin/kafka-reassign-partitions.sh \
  --bootstrap-server three-kafka-bootstrap:9092 \
  --generate \
  --zookeeper localhost:2181 \
  --broker-list 0,1,2,3,4 \
  --topics-to-move-json-file /tmp/topics-to-move.json \
  > /tmp/reassignment.json
```

Inspect the `/tmp/reassignment.json` file to ensure that the recommended
allocation seems sane, then to apply it, run:


```
/opt/kafka/bin/kafka-reassign-partitions.sh \
  --bootstrap-server three-kafka-bootstrap:9092 \
  --execute \
  --zookeeper localhost:2181 \
  --broker-list 0,1,2,3,4 \
  --topics-to-move-json-file /tmp/topics-to-move.json \
  --reassignment-json-file /tmp/reassignment.json
```

You may also need to do this to decrease the replication factor.

[1]: https://console-openshift-console.apps.smaug.na.operate-first.cloud/k8s/ns/opf-kafka/
[2]: https://github.com/operate-first/apps/tree/master/kfdefs/overlays/moc/smaug/opf-kafka
[3]: https://github.com/operate-first/apps/tree/master/kafka/overlays/smaug
[4]: https://github.com/operate-first/SRE/issues/382
[5]: https://console-openshift-console.apps.smaug.na.operate-first.cloud/k8s/ns/openshift-operators/pods
