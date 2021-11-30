# Provision Superset Access

## For Smaug cluster
To provision Superset access to an individual user, we have a Superset rolebinding that provides [Alpha level](https://superset.apache.org/docs/security) access.

Steps:
1. Fork/Clone https://github.com/operate-first/apps
2. Navigate to [this location](https://github.com/operate-first/apps/tree/master/cluster-scope/base/user.openshift.io/groups/superset-user).
3. Add the github users to [this](https://github.com/operate-first/apps/blob/master/cluster-scope/base/user.openshift.io/groups/superset-user/group.yaml) ocp group.
4. Make a PR

If you would like to give another OCP `group` access to Superset follow the instructions [here](map_groups_to_roles.md).
