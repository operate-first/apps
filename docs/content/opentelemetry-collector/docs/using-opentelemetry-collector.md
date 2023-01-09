# Collecting OpenTelemetry data

Red Hat distributed tracing data collection enables collection of OpenTelemetry (OTLP) data with the OpenTelemetry Collector.
From the collector, data can be exported to the backend telemetry analysis tool of choice.

OpenTelemetry Operator is currently deployed and
available on the Smaug cluster. This operator manages all `OpenTelemetryCollector` custom resources in the cluster.
Project owners can create namespaced `OpenTelemetryCollector` custom resources.

Documentation for the distributed tracing data collection can be found [here](https://catalog.redhat.com/software/operators/detail/615486a469cb9f1af5ba7421).

With this operator deployed, anyone can create an `OpenTelemetryCollector` instance in their own namespace. When this
custom resource is created, the components necessary to collect OpenTelemetry data are deployed
in that namespace. If an application running in the namespace is instrumented to export OTLP data, this data can be collected by the
OpenTelemetry Collector, and then exported to the telemetry backend of choice for logging, metrics, and/or tracing.

> NOTE
When following OpenShift distributed tracing documentation and examples, the Jaeger operator
and the OpenTelemetry operator are already deployed in the Smaug cluster. Their custom resources work
together to provide a complete solution for collecting, exporting, and visualizing trace data.
Working with examples or tutorials for collecting OTLP data, begin by creating the Jaeger and OpenTelemetryCollector
custom resources.

## Links and Resources
- [OpenShift distributed tracing data collection (OpenTelemetry Operator) docs](https://catalog.redhat.com/software/operators/detail/615486a469cb9f1af5ba7421).
- [OpenTelemetry Operator repository](https://github.com/open-telemetry/opentelemetry-operator)
- [OpenTelemetry & Jaeger blog](https://cloud.redhat.com/blog/using-opentelemetry-and-jaeger-with-your-own-services/application)
