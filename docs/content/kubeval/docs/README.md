# Kubeval validation

As a part of our CI pipelines in `apps` repository we are using kubeval to validate our schemas. Kubeval checks validity of the CRDs against the schemas stored in schema-store repository. If there are any errors, it is reported. This approach will check for api errors that can sneak through the `kustomize build` command. For example in following manifest `spec.port.targetPort` is not valid:

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: kafdrop-route
spec:
  port:
    targetPort: null
  to:
    kind: Service
    name: kafdrop
```

This manifest will be properly build using `kustomize build` but `kubeval` will be able to catch this issue and report it back.

## Usage

We can use kubeval on manifests which are either stored in files or we can input manifests from stdin. This is useful in our case, because we can pipe output from `kustomize build` to kubeval and check if manifests are correct.

By default `kubeval` uses default schemas which can be found [here](https://kubernetesjsonschema.dev). This is not ideal in our case because we have many CRDs which do not have schemas in default repository. For this reason we are generating our own schemas and using them in kubeval (more about how we are generating and updating schemas can be found [here](https://www.operate-first.cloud/apps/content/kubeval/updating_schema_store.html) and script used for generating schemas can be found [here](https://github.com/operate-first/toolbox/blob/master/scripts/test-kubeval-validation)). To use generated schemas we are using `--schema-location` option.

We are also using `--strict` option which allows no additional properties in schema. Last option we specify is `--skip-kinds` which allows us to skip validation of CRDs which don't have valid schemas.
