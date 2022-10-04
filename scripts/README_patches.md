```
git reset cluster-scope
git clean -f cluster-scope
git co cluster-scope

set -o allexport ; source scripts/jsonnet/group.env; set +o allexport ; scripts/create_jsonnet_group.sh
set -o allexport ; source scripts/jsonnet/namespace.env; set +o allexport ; scripts/create_namespace.sh
set -o allexport ; source scripts/jinja/rbac.env; set +o allexport ; scripts/create_rbac.sh
set -o allexport ; source scripts/jsonnet/namespace.env; source scripts/jsonnet/group.env ; set +o allexport ; scripts/create_namespace_rbac.sh

git add cluster-scope
git diff --cached
```