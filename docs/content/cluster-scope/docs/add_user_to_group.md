# Adding User to an OCP team

All user groups can be found [here][groups].

Find the folder that corresponds with your group and append the `group.yaml` file within that directory.

# Making a user cluster admin

Cluster admins are handled on a per-cluster basis.

To add a user as a cluster admin for a particular cluster, add the GitHub handle associated with that user to this file
 `cluster-scope/overlays/prod/${ENV}/${CLUSTER}/groups/cluster-admins.yaml`.

[groups]: https://github.com/operate-first/apps/tree/master/cluster-scope/base/user.openshift.io/groups
