# Vector on Operate First

We deploy and manage instances of [Vector][Vector] on the Operate First `Smaug` cluster.

Currently we use Vector for forwarding [CLO][CLO] logs from our [Kafka instance][Kafka] to our [Loki][Loki] instance.

You can find our Vector configurations [here][config]. If you would like to make use of this instance, you can submit a PR with an edit to this configuration.

[Vector]: https://github.com/vectordotdev/vector
[CLO]: https://docs.openshift.com/container-platform/4.9/logging/cluster-logging-external.html
[Kafka]: ../../kafka/README.md
[Loki]: ../loki/README.md
[config]: https://github.com/operate-first/apps/tree/master/observatorium/overlays/moc/smaug/vector/smaug/configmap.yaml
