# Provision Superset Access

## For Smaug cluster
To provision Superset access to an individual user, we have a Superset rolebinding that provides [Alpha level][1] access.

Steps:
1. Fork/Clone https://github.com/operate-first/apps
2. Navigate to [this location][2].
3. Add the github users to [this][3] ocp group.
4. Make a PR

If you would like to give another OCP `group` access to Superset follow the instructions [here][4].

[1]: https://superset.apache.org/docs/security
[2]: https://github.com/operate-first/apps/tree/master/cluster-scope/base/user.openshift.io/groups/superset-user
[3]: https://github.com/operate-first/apps/blob/master/cluster-scope/base/user.openshift.io/groups/superset-user/group.yaml
[4]: map_groups_to_roles.md
