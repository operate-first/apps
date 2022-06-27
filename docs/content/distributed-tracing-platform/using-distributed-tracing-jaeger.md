# OpenShift distributed tracing platform to export and visualize OpenTelemetry data

OpenShift distributed tracing platform is based on Jaeger and it enables visualization of trace data.

Red Hat distributed tracing platform is currently deployed and available on the Smaug cluster.

Documentation for the distributed tracing operator can be found [here](https://catalog.redhat.com/software/operators/detail/5ec54a5c78e79e6a879fa271).

With this operator deployed, anyone can create a jaeger instance in their own namespace. When a jaeger
custom resource is created, the components necessary to collect and visualize trace data are deployed
in that namespace. These include a service, configmap, deployment, and route. The jaeger agent, collector, query,
ingester, and UI will be running in that namespace. The jaeger collector can be configured to collect directly
from your application or from an intermediate OpenTelemetry collector. Once connected, use the Jaeger UI to
visualize trace data from your application.

**NOTE**

```
When following OpenShift Jaeger & distributed tracing documentation and examples, the Jaeger operator is
already deployed. With your namespace and application, start with the steps to deploy a Jaeger custom resource.
```

## Links and Resources
- [OpenShift distributed tracing (Jaeger Operator) docs](https://catalog.redhat.com/software/operators/detail/5ec54a5c78e79e6a879fa271)
- [Deploying Jaeger custom resource blog](https://www.opensourcerers.org/2022/05/30/using-opentracing-and-jaeger-with-your-own-services-application/)
