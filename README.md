# ODH

This repo contains manifests to install opendatahub.io

## Folders

This repository serves multiple purposes. To differentiate, we organize this repo in folders - each folder in the repo root per purpose

```
odh
├── kfdef
│   ├── jupyterhub
│   │   ├── kfdef.yaml
│   │   ├── kustomization.yaml
│   │   └── manifests
│   │       └── ...
│   └── superset
│       ├── kfdef.yaml
│       ├── kustomization.yaml
│       └── manifests
│           └── ...
└── operator
    └── base
        ├── ...
        └── kustomization.yaml
```

### Operator

Folder `operator` hosts manifests for ODH operator deployment. When deployed, it creates a subscription to this operator.

### Kfdef

`kfdef` folder hosts `kfdef.yaml` definitions for our deployments. For easier maintenance we prefer to deploy ODH components into separate namespaces. Each sub-folder in the `kfdef` folder hosts a deployment configuration for a single component or a closely related subset of components. When deployed, each of these configurations (sub-folders) can live in a separate namespace.

Within each namespace folder, you can find:

- `kfdef.yaml` - Prescription to what ODH components should be deployed here.
- `kustomization.yaml` - For deploying into ArgoCD via `kustomize`.
- `manifests` folder - This serves as thin modification layer on top of ODH. It allows us to overwrite files which are already present in the upstream [odh-manifests](https://github.com/opendatahub-io/odh-manifests/).

Note: The `manifests` folder can also contain a full set of resource manifests for new, additional components, that are not yet part of ODH. We aim to get these components to the ODH upstream, though for the time being we stage them in here, so we can work on operating them properly in advance.

#### How does overriding work in ODH?

We implement the 2nd approach mentioned in [Open Data Hub and Kubeflow installation customization](https://developers.redhat.com/blog/2020/07/23/open-data-hub-and-kubeflow-installation-customization/) blog post.

We essentially place our modified files on same relative path (within `repoRef.path`) as they are located in `odh-manifests` and then declare this override as a new application after the upstream one. This will copy our modified file over the original and since that resource file is already present in the upstream `kustomization.yaml`, it will be applied.

Let's say we want to modify [`jupyterhub/jupyterhub/base/jupyterhub-configmap.yaml`](https://github.com/opendatahub-io/odh-manifests/blob/master/jupyterhub/jupyterhub/base/jupyterhub-configmap.yaml). We place our modified file at `kfdef/jupyterhub/manifests/base/jupyterhub-configmap.yaml` and modify the `kfdef.yaml`:

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
        path: kfdef/jupyterhub/overrides
    name: jupyterhub
  repos:
  ...
  - name: manifests
    uri: https://github.com/opendatahub-io/odh-manifests/tarball/master
  - name: of-overrides
    uri: https://github.com/operate-first/odh/tarball/master
```
