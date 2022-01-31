# Cluster management application organization

In this directory we declaratively store cluster resources and other privileged resources that are not accessible by project admins.

## Application folder structure

This directory adheres to the following structure:

```text
cluster-scope
.
├── base
│   └── <resource_api_group>
│       └── <resource_kind_plural>
│           └── <resource_metadata_name>
│               ├── kustomization.yaml
│               └── <resource_kind_singular>.yaml
├── bundles
│   └── <operator>
│       ├── kustomization.yaml
├── components
│   ├── <descriptive_component_name>
│   └── kustomization.yaml
└── overlays
    └── <env>
        └── <cluster_name>
            ├── <additional_overlay_files_or_folders>
            └── kustomization.yaml
```

The directories and files in this structure fulfill the following purpose:

#### base/
- `<resource_api_group>` : All resources are stored under their respective API Groups e.g. an OCP `Group` would be organized under `user.openshift.io`
- `<resource_kind_plural>` : Each resource kind managed by this application has a folder using the resource name in plural format, e.g. `clusterroles` or `namespaces`.
- `<resource_metadata_name>` : The name of the resource deployed at cluster scope. It must match the resource `.metadata.name` in `<resource_kind_singular>.yaml`. Since this resource is deployed at the cluster scope, its name has to be unique.
- `kustomization.yaml` : Kustomization file including a single resource, which is a sibling file within the folder. Can pull in `components` for additional bootstrapping.
- `<resource_kind_singular>.yaml` : **Single** resource manifest with a `.spec` that can be deployed to all the clusters.

#### bundles/
Bundled manifests are manifests that are dependent on each other and should be deployed together on the same cluster. You should create a bundle that references all these manifests from a single kustomization.yaml file following the structure above. This bundle can then be easily imported to the target cluster's by adding it to `overlays/<env>/<cluster_name>/kustomization.yaml`. Bundle related resources by including (or removing) a single line in the relevant overlay.
  - `<bundle-name>` : The resource that is being bundled.
  - `kustomization.yaml` : The list of the resources that belong to the operator.

#### components/
Bootstrapping components pulled into `base` (this is different to the standard usage in Kustomize!).
- `<descriptive_component_name>` : Folder describing intention of the component. Can be a grouping folder for additional nested components (by the subject), e.g. `project-admin-rolebinding` component is expected to define project admin `RoleBinding` and within this folder there are nested components for each specific user group.
- `kustomization.yaml` : Kustomization file including a all the resources required for this component. All resources are sibling files to this file.

#### overlays/
Contains an overlay per managed environment/cluster. Only overlaying manifests from `base` is supported.
- `<env>` : The environment to which a cluster belongs.
- `<cluster_name>` : A folder per each managed cluster defining. Path to this folder is specified in the `Application` resource for cluster management application.
- `kustomization.yaml` : Cluster specific Kustomization file with a list of all resources pulled from base. This resource list is ordered alphabetically so it matches the order as it appears in file tree.
- `additional_overlay_files_or_folders` : Additional overlayed files, folders, secret generators etc.

Note: Exceptions are made for custom resource quotas, and other namespace scoped resources that are similarly coupled to a namespace, but are under the purview of the cluster administrators. These are generally stored alongside namespaces i.e. `base/core/namespaces/<namespace_name>/`.

## Creating new resources

1. Create the resource in `base` folder.
2. Pull the resource in desired `overlay`s.

> For adding a custom resource quotas follow instructions as outlined [here](../docs/content/cluster-scope/add_resource_quotas.md)

## Updating existing resource in base

If you desire to update a resource in `base`, please consider if your changes are not overlay/cluster specific. If it is, rather update the resource in your cluster overlay.

If you think this change should be applied to all the clusters, please proceed to update it in the `base`. Verify what clusters are using this resource in their overlays and request an approver for all the effected clusters to review your PR.

## Updating existing resource in components

Updating a resource in a `component` requires you to verify all the usages of the component and what overlays are transitively affected. Please request review accordingly. This is similar to making changes to `base` resources.
