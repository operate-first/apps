# Add Trino database

Follow these instructions to add a Trino database to an OPF managed Superset instance.

## Pre-requisites:

1. Have a user/password with access to a Trino database ready
2. Access to Superset with a role that can add databases, to get access see [here](add_superset_users.md)
3. Trino URL ready, and know the Trino catalog name

(e.g. URLs for [smaug][trino-smaug], [os-cl1][trino-cl1], [osc-cl2][trino-cl2])

## Steps

Navigate to the Superset instance for which you would like to add a database, for example:
  * Superset on [Smaug][s-smaug]
  * Superset on [OSC-CL1][s-cl1]
  * Superset on [OSC-CL2][s-cl2]


Login to Superset. Navigate to `Data` at the top menu

Click `Databases` in the drop down.

Click the `+ Database` button. Select `Presto`.

In the floating window that pops up, choose a meaningful Display Name.

For the `SQLALCHEMY URI`, formulate the URI as per [these][s-uri] instructions (use the expected connection string).
The port should be `443`.
Test the connection. If it succeeds click `Connect`. You are done.

If it fails, verify above steps/info is accurate. If it is, please contact us on our [slack][] in `#support` or
make a GH issue in our [support][] repo.

[trino-smaug]: https://trino.operate-first.cloud
[trino-cl1]: https://trino-secure-odh-trino.apps.odh-cl1.apps.os-climate.org
[trino-cl2]: https://trino-secure-odh-trino.apps.odh-cl2.apps.os-climate.org
[s-smaug]: https://superset.operate-first.cloud/superset/welcome/
[s-cl1]: https://superset-secure-odh-superset.apps.odh-cl1.apps.os-climate.org
[s-cl2]: https://superset-secure-odh-superset.apps.odh-cl2.apps.os-climate.org
[s-uri]: https://superset.apache.org/docs/databases/trino
[support]: https://github.com/operate-first/support
[slack]: https://join.slack.com/t/operatefirst/shared_invite/zt-o2gn4wn8-O39g7sthTAuPCvaCNRnLww
