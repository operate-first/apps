# Adding an OCP group to Operate First Cloud

Instructions on how to add an OCP group to Operate First Cloud.

1. Set your GitHub username, your choice of OCP group, and your workingdir:
```bash
OCP_GROUP=<enter-your-group-here>
GITHUB_USER=<your-github-user-handle>
WORKING_DIR=<path-to-your-working-dir>
```

2. Fork/Clone apps repo https://github.com/operate-first/apps.git:
```bash
# After forking
$ git clone https://github.com/$GITHUB_USER/apps.git $WORKING_DIR
```

3. Navigate to the `base` OCP `groups` directory:
```bash
$ cd $WORKING_DIR/apps/cluster-scope/base/user.openshift.io/groups/
```

4. Create your `$OCP_GROUP` folder:
```bash
$ mkdir $OCP_GROUP
$ cd $OCP_GROUP
```

5. Create `group.yaml` in $OCP_GROUP
```bash
$ cat <<EOF > group.yaml
apiVersion: user.openshift.io/v1
kind: Group
metadata:
    name: $OCP_GROUP
users: []
EOF
```

Add users to the `users` field accordingly.

6. Create the `kustomization.yaml`
```bash
$ cat <<EOF > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
    - group.yaml
EOF
```

7. Add the following line to `cluster-scope/overlays/prod/common/kustomization.yaml` alphabetically:
```
- ../../../base/user.openshift.io/groups/$OCP_GROUP
```

8. Commit and push your changes. Submit a PR to the upstream repository.
