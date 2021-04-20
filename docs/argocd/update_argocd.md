# Steps for Upgrading ArgoCD

Here's a list of relevant release pages you might find useful:
- ArgoCD releases: [link](https://github.com/argoproj/argo-cd/releases)
- KSOPS releases: [link](https://github.com/viaduct-ai/kustomize-sops/releases)
- Kustomize releases: [link](https://github.com/kubernetes-sigs/kustomize/releases)
- SOPS releases: [link](https://github.com/mozilla/sops/releases)
- Helm-Sercrets releases: [link](https://github.com/zendesk/helm-secrets/releases)

First checkout the upgrade docs [here](https://argoproj.github.io/argo-cd/operator-manual/upgrading/overview/) to see if there have been any major/breaking changes, or additional steps that will be required when updating between versions.

# Determine version Number

The version number will be referred throughout this doc, it takes the form of `X.X.X-Y`. Where `X.X.X` refers to the ArgoCD version number, and the `-Y` suffix, refers to our custom version that iterates on the `X.X.X` ArgoCD version. The `-Y` value indicates the version number for our custom tooling. If we are simply updating the custom tooling, then we only bump `-Y` value. For example if we are updating our custom tooling for `1.7.8-1` but keeping ArgoCD at `1.7.8` then we would bump the version to `1.7.8-2`.

We'll use `X.X.X-Y` as the placeholder for this value throughout the doc.

# Update custom ArgoCD image
Bump the `ARGO_CD_VERSION` to the new ArgoCD Version. If upgrading `KSOPS` then also bump `KSOPS_VERSION` to the newer version. Similarly change `SOPS_VERSION` and `HELM_SECRETS_VERSION` if needed.

We don't need to build/push this image, this will happen automatically when we create a tag release at the end.

# Updating Redis image
Upstream uses `redis` on docker for their image, we prefer to use `quay` so we don't encounter rate-limit issues. Unfortunately this means we need to also push a new `redis` image to our `quay` org whenever newer `redis` is introduced in `ArgoCD`.

Check [here](https://github.com/argoproj/argo-cd/blob/master/manifests/install.yaml), under the tag appropriate ArgoCD version tag. Search for the `redis` deployment and see if the tag version for `redis` under `containers/0/image` has been updated. If it has, then push this new image onto `quay.io/operate-first/redis`. For example, if adding `redis:5.0.10-alpine` we would do the following:

```
$ podman pull redis:5.0.10-alpine
$ podman push redis:5.0.10-alpine quay.io/operate-first/redis:5.0.10-alpine
```

Next, under the `images` section [here](https://github.com/operate-first/continuous-deployment/blob/master/manifests/base/kustomization.yaml) update the `newTag` field for the `redis` image accordingly. Folowing from our example above, we would have the following new image in our `Kustomization`:

```yaml
  - name: redis
    newName: quay.io/operate-first/redis
    newTag: 5.0.10-alpine
```

# Update remote Kustomize URLs
If updating ArgoCD's version, bump the remote image references in the following remote references:
- ArgoCD namespace manifests [here](https://github.com/operate-first/continuous-deployment/blob/master/manifests/base/kustomization.yaml#L4)
- ArgoCD cluster rbac [here](https://github.com/operate-first/continuous-deployment/blob/master/manifests/crds/kustomization.yaml#L5)

Do a search for other references to `github.com/argoproj/argo-cd` remote references and update accordingly where applicable.

# Update Container Images
Under the `images` section [here](https://github.com/operate-first/continuous-deployment/blob/master/manifests/base/kustomization.yaml), update the `operate-first/argocd` tag to `vX.X.X-Y`. For example, if updating to `v1.8.1-2` we would have the following new image in our `Kustomization`:

```yaml
  - name: argoproj/argocd
    newName: quay.io/operate-first/argocd
    newTag: v1.8.1-2
```

# Update toolbox
If updating any of the custom tooling (e.g. sops, ksops, helm, helm-secrets, etc.), these changes should also be brought to `operate-first/toolbox`, simply update the Dockerfile [here](https://github.com/operate-first/toolbox/blob/master/Dockerfile), you will likely only need to update the version variables.

Update the version in the readme (to the version we'll be tagging), and cut a new tag so that a new tag-release build is initiated.

# Update Docs

We make an attempt to list the current versions of our tooling [here](https://github.com/operate-first/continuous-deployment/blob/master/docs/publish/versions.md). So update these accordingly.

# Create a release
Create a new tag in the form of `vX.X.X-Y`, where `X.X.X-Y` should resolve to the version number as described [here](#determine-version-number). This tag will be used by downstream, and should never be changed once it's created.

Once the tag is created, a bot will create the build and publish it to [https://quay.io/operate-first/argocd](https://quay.io/operate-first/argocd).
