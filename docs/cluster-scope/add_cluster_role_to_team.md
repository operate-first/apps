# Binds a given role to a group for specified namespace

To give a team admin, edit, or view access to a namespace, you can use the following script:

```bash
# From the root of this repo
$ bash scripts/add-cluster-role-to-team.sh <admin/edit/view> NAMESPACE OWNER-TEAM
```

Example:

```bash
$ bash scripts/add-cluster-role-to-team.sh view kubeflow operate-first
```
