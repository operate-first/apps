We are using the Strimzi Operator to manage our instance of Kafka.

## Kafka Access

Here are the broker URLs For Kafka:
  * For external acces use `odh-message-bus-kafka-bootstrap-opf-kafka.apps.zero.massopen.cloud:443`
  * For internal access within `MOC/Zero` cluster use `odh-message-bus-kafka-bootstrap.opf-kafka.svc:9093`

## SSL Certs
To send/receive messages in Kafka you will need a topic and also credentials/certs to be able to access that topic.

Credentials/certs are generated per `KafkaUser` bases.

To create a new kafka topic or kafka user, please make an issue in [this repo](https://github.com/operate-first/support/issues/new?assignees=&labels=user-support&template=kafka_user_topic_request.md&title=) requesting access.

*If you want to do the above task yourself, you can look at the following docs for instructions:*

## Adding Kafka topics

To add Kafka topics see [here](add_kafka_topics.md).

## Adding Kafka users

To add Kafka users see [here](add_kafka_users.md).
