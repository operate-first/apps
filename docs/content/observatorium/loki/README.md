# Loki Access

[Loki][1] is a horizontally-scalable, highly-available, multi-tenant log aggregation system.

An instance of Loki is available for use in Operate First.

## Requesting Loki access

Logs from Loki can be accessed in two different ways:

1. Using the Grafana Console
2. Using the Loki Query-API

### Grafana Console access
The Operate First Grafana console can be accessed at: https://grafana.operate-first.cloud/

To request access to the Grafana Console, read the [following guide][2].

### Loki Query API access
The Loki Query API can be accessed at:

https://loki-frontend-opf-observatorium.apps.smaug.na.operate-first.cloud/

To request access to the Loki Query API, read the [following guide][3].

Some documentation about the Loki Query API is available [here][4].

While querying Loki for logs,
you will need to have a header `'X-Scope-OrgID'` set in your requests.
This header (OrgID) is used to identify tenants in a multi tenancy setup ([more info][5]).

[1]: https://github.com/grafana/loki#loki-like-prometheus-but-for-logs
[2]: ../thanos/request_grafana_access.md
[3]: request_loki_access.md
[4]: https://grafana.com/docs/loki/latest/api/
[5]: https://grafana.com/docs/loki/latest/operations/multi-tenancy/
