# Jaeger for visualizing traces

Red Hat distributed tracing platform is based on Jaeger. Jaeger enables visualization of trace data.

Jaeger Operator is currently deployed and available on the Smaug cluster.
This operator manages all `Jaeger` custom resources in the cluster. Project owners can create namespaced `Jaeger` custom resources.

Documentation for the distributed tracing platform operator can be found [here](https://catalog.redhat.com/software/operators/detail/5ec54a5c78e79e6a879fa271).

With this operator deployed, anyone can create a jaeger instance in their own namespace. When a jaeger
custom resource is created, the components necessary to collect and visualize trace data are deployed
in that namespace. These include a service, configmap, deployment, and route. The jaeger agent, collector, query,
ingester, and UI will be running in that namespace. The jaeger collector can be configured to collect directly
from your application or from an intermediate OpenTelemetry collector. Once connected, use the Jaeger UI to
visualize trace data from your application.

> NOTE
OpenShift distributed tracing documentation will recommend installing the Jaeger operator. The Jaeger operator is
already deployed in Smaug cluster. In tutorials and examples, start with the steps to deploy a Jaeger custom resource.
The OpenTelemetry Operator is also deployed in the Smaug cluster. Refer to the OpenTelemetry & Jaeger blog below
to combine the Jaeger and OpenTelemetryCollector custom resources for collecting and visualizing traces.

## Links and Resources
- [OpenShift distributed tracing (Jaeger Operator) docs](https://catalog.redhat.com/software/operators/detail/5ec54a5c78e79e6a879fa271)
- [Deploying Jaeger custom resource blog](https://www.opensourcerers.org/2022/05/30/using-opentracing-and-jaeger-with-your-own-services-application/)
- [OpenTelemetry & Jaeger blog](https://cloud.redhat.com/blog/using-opentelemetry-and-jaeger-with-your-own-services/application)
