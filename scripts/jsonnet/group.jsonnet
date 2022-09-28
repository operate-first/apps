local name = std.extVar('GROUP');
local users = std.extVar('USERS');
local dir  = "cluster-scope/base/user.openshift.io/groups/" + name + "/";

{
  [dir + "group.yaml"]: {
    apiVersion: "user.openshift.io/v1",
    kind: "Group",
    metadata: {
      name: name,
    },
    users: users,
  }
}