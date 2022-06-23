# Provision Superset Access

## For Smaug cluster
To provision Superset access to an individual user, we have a Superset rolebinding that provides [Alpha level][1] access.

Steps:
1. Fork/Clone https://github.com/operate-first/apps
2. Navigate to [this location][2].
3. Add the github users to [this][3] ocp group. Make sure that the usernames are lowercase.

> Note: To give a user admin access, add them to the [superset-admins][admingroup] instead.

4. Make a PR

If you would like to give another OCP `group` access to Superset follow the instructions [here][4].

## For OSC clusters:
1. Fork/Clone https://github.com/operate-first/apps
2. Add GitHub usernames that need access to the following group:
    * For OSC-cl1 add users to [this group][5-1]
    * For OSC-cl2 add users to [this group][5-2]
    * As of this writing all users are by default given admin access to Superset
3. Make a PR
4. Request an invite to [the OSC org][6], and the [odh-env team][7]. You can request it in `#support` channel in our [slack][slack].


[1]: https://superset.apache.org/docs/security
[2]: https://github.com/operate-first/apps/tree/master/cluster-scope/base/user.openshift.io/groups/superset-user
[3]: https://github.com/operate-first/apps/blob/master/cluster-scope/base/user.openshift.io/groups/superset-user/group.yaml
[4]: map_groups_to_roles.md
[5-1]: https://github.com/operate-first/apps/blob/master/cluster-scope/overlays/prod/osc/osc-cl1/groups/odh-users.yaml
[5-2]: https://github.com/operate-first/apps/blob/master/cluster-scope/overlays/prod/osc/osc-cl2/groups/odh-users.yaml
[6]: https://github.com/os-climate
[7]: https://github.com/orgs/os-climate/teams/odh-env-users
[slack]: https://join.slack.com/t/operatefirst/shared_invite/zt-o2gn4wn8-O39g7sthTAuPCvaCNRnLww
[admingroup]: https://github.com/operate-first/apps/tree/master/cluster-scope/base/user.openshift.io/groups/superset-admins
