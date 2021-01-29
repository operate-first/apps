# Cluster management application organization

This is just a short addendum to [ADR 0009](https://www.operate-first.cloud/blueprints/blueprint/docs/adr/0009-cluster-resources.md) declaring the direct consequences and organization structure of this `cluster-scope` application. These are the best practises we expect every maintainer who does changes to this application to follow.

## Application folder structure

- `base`: Contains all the actual resource manifests which can be deployed to any clusters. Manifests are required to be stored in a format that can be applied to all the clusters (no cluster specific `.spec`s).
  - `<RESOURCE_KIND_PLURAL_NAME>`: Each resource kind managed by this application has a folder using the resource name in plural format, e.g. `clusterroles` or `namespaces`.
    - `<RESOURCE_NAME>`: The name of the resource deployed at cluster scope. It must match the resource `.metadata.name` in `<RESOURCE_KIND_SINGULAR_NAME>.yaml`. Since this resource is deployed on cluster scope, its name has to be unique.
      - `kustomization.yaml`: Kustomization file including a single resource, which is a sibling file within the folder. Can pull in `components` for additional bootstrapping.
      - `<RESOURCE_KIND_SINGULAR_NAME>.yaml`: **Single** resource manifest with a `.spec` that can be deployed to all the clusters.
- `components`: Bootstrapping components pulled into `base` (this is different to the standard usage in Kustomize!).
  - `<DESCRIPTIVE_COMPONENT_NAME>`: Folder describing intention of the component. Can be a grouping folder for additional nested components (by the subject), e.g. `project-admin-rolebinding` component is expected to define project admin `RoleBinding` and within this folder there are nested components for each specific user group.
    - `kustomization.yaml`: Kustomization file including a all the resources required for this component. All resources are sibling files to this file.
- `overlays`: Contains an overlay per managed cluster. Does not add any additional manifest. Only overlaying manifests from `base` is supported.
  - `<MANAGED_CLUSTER_NAME>`: A folder per each managed cluster defining. Path to this folder is specified in the `Application` resource for cluster management application.
    - `kustomization.yaml`: Cluster specific Kustomization file with a list of all resources pulled from base. This resource list is ordered alphabetically so it matches the order as it appears in file tree.
    - Additional overlayed files, secret generators etc.

## Creating new resources

1. Create the resource in `base` folder.
2. Pull the resource in desired `overlay`s.

## Updating existing resource in base

If you desire to update a resource in `base`, please consider if your changes are not overlay/cluster specific. If it is, rather update the resource in your cluster overlay.

If you think this change should be applied to all the clusters, please proceed to update it in the `base`. Verify what clusters are using this resource in their overlays and request an approver for all the effected clusters to review your PR.

## Updating existing resource in components

Updating a resource in a `component` requires you to verify all the usages of the component and what overlays are transitively affected. Please request review accordingly. This is similar to making changes to `base` resources.
