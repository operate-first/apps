# Map OCP Group to Superset Role

To map a Superset role to an OCP group do the following:

1. Navigate to the Superset Config file [here][superset_config]
2. Find `AUTH_ROLES_MAPPING` under `stringData.superset_config`
3. Append this python dictionary with the OCP group and Superset Role using
the following format:
```python
    AUTH_ROLES_MAPPING = {
        "cluster-admins": ["Admin"],
        "operate-first": ["Admin"],
        "data-science": ["User"],
        ....
        "<YOUR_OCP_GROUP_HERE>": ["<SUPERSET_ROLES_HERE>", ...],
    }
```

Once done, submit a PR.

[superset_config]: https://github.com/operate-first/odh-manifests/blob/smaug-v1.1.1/superset/base/secret.yaml

Note that the ODH and Superset pod will need to be restarted after the PR is merged.
