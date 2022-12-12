# Steps for Upgrading ArgoCD

Here's a list of relevant release pages you might find useful:
- ArgoCD releases: [link][1]
- KSOPS releases: [link][2]
- Kustomize releases: [link][3]
- SOPS releases: [link][4]
- Helm-Secrets releases: [link][5]

First checkout the upgrade docs [here][6] to see if there have been any major/breaking changes, or additional steps that will be required when updating between versions.

## Changes to operate-first/continuous-deployment

### Determine version Number

The version number will be referred throughout this doc, it takes the form of `X.X.X-Y`. Where `X.X.X` refers to the ArgoCD version number, and the `-Y` suffix, refers to our custom version that iterates on the `X.X.X` ArgoCD version. The `-Y` value indicates the version number for our custom tooling. If we are simply updating the custom tooling, then we only bump `-Y` value. For example if we are updating our custom tooling for `1.7.8-1` but keeping ArgoCD at `1.7.8` then we would bump the version to `1.7.8-2`.

We'll use `X.X.X-Y` as the placeholder for this value throughout the doc.

### Update Dockerfile

Fork/Clone the `operate-first/continuous-deployment` repo.

Open the `Dockerfile` and bump the `ARGO_CD_VERSION` to the new ArgoCD Version. If upgrading `KSOPS` then also bump `KSOPS_VERSION` to the newer version. Similarly change `SOPS_VERSION` and `HELM_SECRETS_VERSION` if needed.

Create a pull request.

### Create tag release

Once it's merged create a new tag in the `operate-first/continuous-deployment` in the form of `vX.X.X-Y`, where `X.X.X-Y` should resolve to the version number as described [here][14]. This tag will be used by downstream, and should never be changed once it's created.

Once the tag is created, a bot will create the build and publish it to [https://quay.io/operate-first/argocd][15].

## Changes to operate-first/apps

Fork/Clone the `operate-first/apps` repo.

### Updating Redis image

Upstream uses `redis` on docker for their image, we prefer to use `quay` so we don't encounter rate-limit issues. Unfortunately this means we need to also push a new `redis` image to our `quay` org whenever newer `redis` is introduced in `ArgoCD`.

Check [here][7], under the tag appropriate ArgoCD version tag. Search for the `redis` deployment and see if the tag version for `redis` under `containers/0/image` has been updated. If it has, then push this new image onto `quay.io/operate-first/redis`. For example, if adding `redis:5.0.10-alpine` we would do the following:

```
$ podman pull redis:5.0.10-alpine
$ podman push redis:5.0.10-alpine quay.io/operate-first/redis:5.0.10-alpine
```

Next, under the `images` section [here][8] update the `newTag` field for the `redis` image accordingly. Folowing from our example above, we would have the following new image in our `Kustomization`:

```yaml
  - name: redis
    newName: quay.io/operate-first/redis
    newTag: 5.0.10-alpine
```

### Update ArgoCD Manifests
If updating ArgoCD's version, perform the following:
-   Bump image ref to the new custom image in the root `Kustomization` [here][9].
-   Ensure the `CustomResourceDefinition`, `ClusterRoles`, `ClusterRoleBindings` in the `cluster-scope` app are synced with upstream for the new `ArgoCD` version.

    To do this, run the following from repo root:
    ```bash
    # TAG is a tag from https://github.com/argoproj/argo-cd/tags
    $ ./scripts/argocd/update_cluster_resources.sh ${TAG}
    ```
- Do a search for other references to `github.com/argoproj/argo-cd` update accordingly where applicable.

### Update Container Images

Under the `images` section [here][11], update the `operate-first/argocd` tag to `vX.X.X-Y`. For example, if updating to `v1.8.1-2` we would have the following new image in our `Kustomization`:

```yaml
  - name: argoproj/argocd
    newName: quay.io/operate-first/argocd
    newTag: v1.8.1-2
```

Run a manual `kustomize build` for the `argocd` overlay, and ensure that the images are updated in the deployment specs as intended.

## Changes to operate-first/toolbox

If updating any of the custom tooling (e.g. sops, ksops, helm, helm-secrets, etc.), these changes should also be brought to `operate-first/toolbox`, simply update the Dockerfile [here][12], you will likely only need to update the version variables.

Update the version in the readme (to the version we'll be tagging), and cut a new tag so that a new tag-release build is initiated.

## Update Docs

We make an attempt to list the current versions of our tooling [here][13]. So update these accordingly.

[1]: https://github.com/argoproj/argo-cd/releases
[2]: https://github.com/viaduct-ai/kustomize-sops/releases
[3]: https://github.com/kubernetes-sigs/kustomize/releases
[4]: https://github.com/mozilla/sops/releases
[5]: https://github.com/zendesk/helm-secrets/releases
[6]: https://argoproj.github.io/argo-cd/operator-manual/upgrading/overview/
[7]: https://github.com/argoproj/argo-cd/blob/master/manifests/install.yaml
[8]: https://github.com/operate-first/apps/blob/master/argocd/base/kustomization.yaml
[9]: https://github.com/operate-first/apps/blob/master/argocd/base/kustomization.yaml#L4
[10]: https://github.com/operate-first/continuous-deployment/blob/master/manifests/crds/kustomization.yaml#L5
[11]: https://github.com/operate-first/apps/blob/master/argocd/base/kustomization.yaml#L16
[12]: https://github.com/operate-first/toolbox/blob/master/Dockerfile
[13]: https://github.com/operate-first/continuous-deployment/blob/master/README.md
[14]: #determine-version-number
[15]: https://quay.io/operate-first/argocd
[16]: https://github.com/operate-first/apps/tree/master/cluster-scope/base
[17]: https://github.com/argoproj/argo-cd/tree/master/manifests
