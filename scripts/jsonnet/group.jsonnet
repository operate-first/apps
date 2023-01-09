local name = std.extVar('GROUP');
local users = std.extVar('USERS');
{
  apiVersion: "user.openshift.io/v1",
  kind: "Group",
  metadata: {
    name: name,
  },
  users: users,
}
