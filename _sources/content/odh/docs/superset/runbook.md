# Superset Runbook

## Key Locations

| Env            | Namespace                | GitHub Repo  |
| -------------- | ------------------------ | ------------ |
| MOC-Smaug Prod | [opf-superset][superset] | [repo][repo] |

## Common errors

### ValueError: Invalid decryption key

When rebooting superset, the initcontainer may crash and report `ValueError: Invalid decryption key` in the logs.

To fix this you may have to set the secret key to null so it may be refreshed. Follow these steps:

Run the following:

> NOTE: that running the following will clear the passwords for the databases in superset, and will need to be re-entered

```bash
$ oc rsh ${SUPERSET_DB_POD}
sh-4.2$ psql
postgres=# \connect supersetdb
supersetdb=# UPDATE public.dbs SET password = null;
supersetdb=# UPDATE public.dbs SET encrypted_extra = null;
```

Explained more [here][1]

### Duplicate key value violates unique constraint

When rebooting superset, the init container might report `duplicate key value violates unique constraint`.

This happens when [oauth mapping][oauth-mapping] has overlapping users. If one user is in multiple groups then it will
try to add the user twice, but run in to a conflict. Ensure that this is not the case.

### Trino Error in Superset

If you keep seeing "Trino errors show up" and in super logs you see:
```
requests.exceptions.ConnectionError: ('Connection aborted.', RemoteDisconnected('Remote end closed connection without response'))
INFO:trino.exceptions:failed after 3 attempts
```
Try going to `Data > Databases` at the top, open edit panel for `opf-trino` database. Test the connection.
If it reports an error, try adding in the password again where it says `XXX..` and see if that works.

### Can't find user when adding them to a Chart

When adding a user to a chart, you may not be able to see the user.

![](img/nouser.png)

In this example a user by the name of "Karan" could not be found.

1. First ensure that the user has logged into Superset at least once (so that the user is created within Superset)
2. When adding users to charts, you may see a lot of _blank_ lines in the user list dropdown, these empty lines
represent users that have not updated their First/Last name within Superset.

Have the user go to `settings` (top right) > `info` > `edit user`. If the user does not have permissions to do this
reach out to an ODH admin, anyone from this list [here][odhadmin] will have the appropriate permissions. Have them
edit this user's name accordingly.

The user should now show up in the drop down list when searched for by First/Last name.

### This endpoint requires datasource $datasource  (Public Dashboards)

When making dashboards public you may encounter an error:

> This endpoint requires the datasources $datasource, database, or `all_datasource_access` permission

Prerequisite:

* Superset Admin

Resolution:

Go to `Settings -> List Roles -> Edit Public role -> Permissions -> Select datasource drop down`

The datasource in the drop down should correspond to the one mentioned in the error. The name may not be exact, but
will likely be of the form: `datasource access on [DATABASE].[$YOUR_DATASOURCE](id:##)` example:
`datasource access on [Trino].[thoth_support_issues](id:83)`

[oauth-mapping]: https://github.com/operate-first/odh-manifests/blob/smaug-v1.1.1/superset/base/secret.yaml#L29
[superset]: https://superset.operate-first.cloud
[repo]: https://github.com/operate-first/apps/tree/master/kfdefs/overlays/moc/smaug/opf-superset
[1]: https://github.com/operate-first/SRE/issues/408
[odhadmin]: https://github.com/operate-first/apps/blob/master/cluster-scope/base/user.openshift.io/groups/odh-admin/group.yaml#L5
