# ODH

This repo contains manifests to install Open Data Hub.

## Directory Structure

We use a combination of [Kustomize Overlays](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/#bases-and-overlays)
and [ODH overrides](https://developers.redhat.com/blog/2020/07/23/open-data-hub-and-kubeflow-installation-customization/) to structure our ODH manifests.

Each folder within 'Bases' and 'Overlays/$ENV' within each folder corresponds to a set of components that will be deployed
in the same namespace. Often times there will be one component per namespace, but this is not always the case. In each
directory you will find:

- `kfdef.yaml` - Prescription to what ODH components should be deployed here.
- `kustomization.yaml` - For deploying into ArgoCD via `kustomize`.
- `overrides` folder (optional) - This serves as thin modification layer on top of ODH. It allows us to overwrite files which are already present in the upstream [odh-manifests](https://github.com/opendatahub-io/odh-manifests/).

Note: The `overrides` folder can also contain a full set of resource manifests for new, additional components, that are not yet part of ODH. We aim to get these components to the ODH upstream, though for the time being we stage them in here, so we can work on operating them properly in advance.

#### How does overriding work in ODH?

We implement the 2nd approach mentioned in [Open Data Hub and Kubeflow installation customization](https://developers.redhat.com/blog/2020/07/23/open-data-hub-and-kubeflow-installation-customization/) blog post.

We essentially place our modified files on same relative path (within `repoRef.path`) as they are located in `odh-manifests` and then declare this override as a new application after the upstream one. This will copy our modified file over the original and since that resource file is already present in the upstream `kustomization.yaml`, it will be applied.

Let's say we want to modify [`jupyterhub/jupyterhub/base/jupyterhub-configmap.yaml`](https://github.com/opendatahub-io/odh-manifests/blob/master/jupyterhub/jupyterhub/base/jupyterhub-configmap.yaml) for our `moc` deployment.

We place our modified file at `odh/overlays/moc/jupyterhub/overrides/base/jupyterhub-configmap.yaml` and modify the `kfdef.yaml`:

```yaml
kind: KfDef
...
spec:
  applications:
  ...
  - kustomizeConfig:
      repoRef:
        name: manifests
        path: jupyterhub/jupyterhub
    name: jupyterhub
  - kustomizeConfig:
      repoRef:
        name: of-overrides
        path: odh/overlays/moc/jupyterhub/overrides
    name: jupyterhub
  repos:
  ...
  - name: manifests
    uri: https://github.com/opendatahub-io/odh-manifests/tarball/master
  - name: of-overrides
    uri: https://github.com/operate-first/apps/tarball/master
```
