# Updating schemas in schema store

Our `apps` repository uses CRDs for which schemas can't be found in default schema repository. This means that we have to use our own schema repository. For this we have used [script](https://github.com/sabre1041/k8s-manifest-validation/blob/main/scripts/build_schema.py) written by Andrew Block. This script generates schemas from OpenAPI specification using [openapi2jsonschema](https://github.com/instrumenta/openapi2jsonschema). We have also extended this script to generate `skip_kinds.txt` which contains names of the CRDs which don't have valid schemas and will not be validated in `kubeval` validation. Script can be found in [schema-store](https://github.com/operate-first/schema-store) repository.
To use this script you will have to login to the cluster with `oc` and run following:

```bash
python build_schema.py -u $(oc whoami --show-server) -t $(oc whoami -t) -s STRICT
```

This script generates a folder called `openshift-json-schema/master-standalone-strict` which contains schemas for all CRDs which are present in this cluster. This script is then used in github actions, where we [run cronjob](https://github.com/operate-first/schema-store/blob/main/.github/workflows/update-schemas.yaml), which generates schemas from each cluster and joins them together. In the end if the PR doesn't exist it is created with new changes or if there is opened PR changes are updated.

# Structure of schema store

Schemas are stored as JSON files in `schemas/` at the root of the repo. The directories within schemas are named using the following format: `${version}-${reference}-${mode}`, where:

```
version = Version of Kubernetes from which schemas were extracted (default for Kubeval is "master").
reference = Refence tells us if JSON schemas contain all the definitions of parameters, or the definitions are referenced in a different file and schema contains only reference to this file.
mode = Mode tells if we are using stronger strict JSON schemas which do not allow arbitrary parameters or weaker JSON schemas which allow arbitrary parameters.
```
