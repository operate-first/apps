# Obtain Cluster Admin Privileges in an Operate First Cluster

## Pre-requisites

1. Be a member of the `sudoers` OCP group in the desired cluster
2. Have access to the desired cluster via the CLI or the OpenShift
console

## To Obtain Cluster Admin Rights from the CLI:

You need to impersonate the system admin identity by running your command
like so
`oc get pods --as system:admin`

This will run the command with administrator priviledges similar to using sudo at the command line.

## To Obtain Cluster Admin Rights from the Openshift Console:

1. Navigate to the `RoleBindings` tab under user management in the OpenShift console dashboard
2. Search for the `cluster-admins` `ClusterRoleBinding` whose subject kind is "user" and whose subject
name is "system:admin"
3. Click the options for this `ClusterRoleBinding` and select `Impersonate User "system:admin"`

You will now be viewing the dashboard as the system:admin user.
