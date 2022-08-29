# Giving a user project role access in the smaug cluster

## Prerequisite
A namespace for the project should already be created before starting.

## Create an OCP group
1. The first step for giving you project role access should be to create an OCP group.
After creating a OCP group you will add your github username to the group.
+ Documentation on creating an OCP group can be found [here](https://www.operate-first.cloud/apps/content/cluster-scope/create_ocp_group.html).
+ The directory that contains all of the OCP groups can be found [here](https://github.com/operate-first/apps/tree/master/cluster-scope/base/user.openshift.io/groups)
2. After you create the group make sure to add your github username to the group by editing the `group.yaml` file.

## Give the group the appropriate rbac(roles and and rolebindings)
After creating a OCP group you must give the group the appropriate roles and rolebindings.

1. Create a directory with the name of your OCP group [here](https://github.com/operate-first/apps/tree/master/cluster-scope/components/project-admin-rolebindings)
copy one of the other directories in that folder and use it as a template.

2. Once the folder is copied, edit the `rbac.yaml` file and change `spec.metadata.name`.

3. Change `spec.subjects.name` to the OCP group created in the previous instructions.

## Add the OCP group to your project/namespace
You have now created the OCP group. You must now add the OCP group to your namespace
1. Open the following file: `cluster-scope/base/core/namespaces/<yourproject>/kustomization.yaml`
2. Add the path of the component that you created in `/apps/cluster-scope/components/project-admin-rolebindings` to the `components` section in the overlay `kustomization.yaml` file corresponding to the cluster you are deploying to. You can see examples of this [here](https://github.com/operate-first/apps/tree/master/cluster-scope/components/project-admin-rolebindings).
