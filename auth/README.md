# Dex

**Warning** This component will be deprecated and replaced by a Keycloak deployment soon. [blueprint#30](https://github.com/operate-first/blueprint/issues/30)

## Change required user access permissions

Update the `dex-cm.yaml` in the target overlay:

```yaml
...
connectors:
  - type: openshift
    ...
    config:
      ...
      groups:
        - list
        - of
        - user
        - groups
```

## Adding a new client

Please add a new static client into the `dex-cm.yaml`:

```yaml
staticClients:
  - id: CLIENT_ID
    name: VERBOSE NAME
    redirectURIs:
      - base_url/suffix/for/callback
    secretEnv: CLIENT_SECRET
```

- `id: CLIENT_ID` will be used as the application client identity (mostly referred to as `ClientId`)
- `name: VERBOSE NAME` is just a name descriptor
- `base_url` is the client application's base URL
- `/suffix/for/callback` is the application OIDC callback endpoint, please consult API documentation of the application
- `CLIENT_SECRET` is a variable name from `dex-client-secrets.yaml` loaded at runtime from environment. Don't use `$` here, value gets evaluated automatically.

Then specify the `CLIENT_SECRET` in `dex-clients.enc.yaml` in your target overlays.

Provide the same `CLIENT_ID` and `CLIENT_SECRET` to the connected applications. These are the credentials the application can use to identify itself against Dex server.
