# Provision Superset Access
To provision Superset access, we have a Superset rolebinding that provides [Alpha level](https://superset.apache.org/docs/security) access.

Steps:
1. Fork/Clone https://github.com/operate-first/apps
2. Navigate to [this location](https://github.com/operate-first/apps/blob/master/cluster-scope/overlays/prod/common/groups/superset-user.enc.yaml).
3. Add the github users to this ocp group.
4. Make a PR
