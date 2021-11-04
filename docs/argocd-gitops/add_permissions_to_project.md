# Requesting more permissions for an ArgoCD Project (MOC)

Once a team has been onboarded to ArgoCD. They may request additional permissions for their ArgoCD Project. For example, a team
may request permissions to deploy a custom resource, but lack the permissions to do so.

Permissions for all projects can be found [here][1].

All projects inherit permissions from the [global project][2].

In general if one project requires additional permissions, then we extend that privilege to other projects, as such we advise just adding to the global project. To do this, simply edit the `global_project.yaml` and add the resource under `namespaceResourceWhitelist`.

For example, to give a project permissions to deploy Argo `Workflows` add the following to `global_project.yaml` located [here][3]:

```yaml
namespaceResourceWhitelist:
    - group: argoproj.io
      kind: CronWorkflow
    - group: argoproj.io
      kind: Workflow
    - group: argoproj.io
      kind: WorkflowTemplate
```

You can also add these permissions to the specific project yaml, if for some reason it's critical only one project has such permissions.

[1]: https://github.com/operate-first/apps/tree/master/argocd/overlays/moc-infra/projects
[2]: https://github.com/operate-first/apps/blob/master/argocd/overlays/moc-infra/projects/global_project.yaml
[3]: https://github.com/operate-first/apps/blob/master/argocd/overlays/moc-infra/projects/global_project.yaml#L6
