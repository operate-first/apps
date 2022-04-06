# Kafka

We are using the Strimzi Operator to manage our instance of Kafka.

## Kafka Access

Here are the broker URLs For Kafka:
  * For external acces use `odh-message-bus-kafka-bootstrap-opf-kafka.apps.smaug.na.operate-first.cloud:443`
  * For internal access within `MOC/smaug` cluster use `odh-message-bus-kafka-external-bootstrap.opf-kafka.svc:9093`

## SSL Certs
To send/receive messages in Kafka you will need a topic and also credentials/certs to be able to access that topic.

Credentials/certs are generated per `KafkaUser` bases.

## Adding Kafka topics

To add Kafka topics follow the instructions [here][1].

## Adding Kafka users

To add Kafka users follow the instructions [here][2].

[1]: add_kafka_topics.md
[2]: add_kafka_users.md
