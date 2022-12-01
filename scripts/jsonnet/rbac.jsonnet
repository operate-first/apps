local group = std.extVar('GROUP');

{
  "apiVersion": "rbac.authorization.k8s.io/v1",
  "kind": "RoleBinding",
  "metadata": {
    "name": "namespace-admin-"+group
  },
  "roleRef": {
    "apiGroup": "rbac.authorization.k8s.io",
    "kind": "ClusterRole",
    "name": "admin"
  },
  "subjects": [
    {
      "apiGroup": "rbac.authorization.k8s.io",
      "kind": "Group",
      "name": group
    }
  ]
}
