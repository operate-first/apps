# Adding permissions in Grafana

All Grafana deployments are configured via OAUTH using the Dex connector. Permissions are distributed by mapping Grafana
[roles][roles] to OCP groups. This is done by updating the `role_attribute_path` as described [here][role_mapping] via
the Grafana CR.

# Give OCP group Grafana role
Navigate to the Grafana CR, for the Grafana instance on the MOC environment [here][moc_environment].
Find the attribute: `role_attribute_path` under `spec.config.auth.generic_oauth`

You will see something like the following:

```yaml
  role_attribute_path: |
    contains(groups[*], 'operate-first') && 'Admin' ||
    contains(groups[*], 'data-science') && 'Viewer' ||
    'Deny'
```

Add a line before `Deny` in the form of `contains(groups[*], '<YOUR_OCP_GROUP>') && '<GRAFANA_ROLE>' ||`.
For example if we wanted to give the OCP group "my-team" the "Editor" Grafana role, we would update the field like so:

```yaml
  role_attribute_path: |
    contains(groups[*], 'operate-first') && 'Admin' ||
    contains(groups[*], 'data-science') && 'Viewer' ||
    contains(groups[*], 'my-team') && 'Editor' ||
    'Deny'
```
Alternatively, if you do not want to create your own group and simply want read-only access to grafana, you can also just add yourself to the [`grafana-viewer` group](https://github.com/operate-first/apps/blob/master/cluster-scope/base/user.openshift.io/groups/grafana-viewer/group.yaml).

Submit a PR with the changes.

[roles]: https://grafana.com/docs/grafana/latest/permissions/organization_roles/
[role_mapping]: https://grafana.com/docs/grafana/latest/auth/generic-oauth/#jmespath-examples
[moc_environment]: https://github.com/operate-first/apps/blob/master/grafana/overlays/moc/smaug/grafana-oauth.yaml
