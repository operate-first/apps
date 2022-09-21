# OpenMetaData Deployment on Operate First

The OpenMetaData (OM) deployment on Operate First leverages the [Helm k8s deployment][1] method. In order to stay
consistent with our other services, the helm chart is converted to kustomize. This can be easily achieved by

```bash
helm repo add open-metadata https://helm.open-metadata.org/

# Get dependencies
helm pull open-metadata/openmetadata-dependencies
tar -xvzf openmetadata-dependencies-${chart-version}>.tgz
helm template --name-template=openmetadata-dependencies .

# Get openmetadata
helm pull open-metadata/openmetadata
tar -xvzf openmetadata-${chart-version}.tgz
helm template --name-template=openmetadata .
```

Further additions/amendments are made to these renders. For the resulting manifests you can find them [here][2].

Some examples of additions include:
* Addition of OCP routes
* Patches to deployments
* Removal of any security context fields, or fields that attempt to change container uid
* Affinity rules

Dependencies should be applied first, they consist of Elasticsearch, Mysql, and Airflow.

# ReadWriteMany Access Mode

The OpenMetaData Dependencies require [ReadWriteMany Access Mode][11]. These pods will attempt to bind the same pvcs for
DAGs and Logs. Operate First Clusters do not have any storage providers that support this. However, we workaround this
by ensuring all such pods are scheduled on the same node allowing them to treat a pvc with `ReadWriteOnce` accessmode
as `ReadWriteMany`, see [here][4] for more info.

# Authentication

There are 2 access points that require authentication. They are as follows:

## OpenMetaData UI

This is configured using the Operate First [OSC-Cl2 Dex Connector][5]. Only the direct GitHub Authentication is supported,
as of now. Authentication via Dex -> Openshift will not work ([issue][6] here). The OM documentation for this
configuration can be found [here][7]. And the configuration is patched [here][9].

## Ingestion

Ingestion authentication is done through JWT tokens. Airflow is used to perform ingestion, and Airflow authenticates
with OM via a JWT token that is generated via the OM UI.

First, for OM to be able to generate tokens, it needs JWT configuration:

This is documented [here][12]. You can find these fields in our configuration manifests [here][8].
```yaml
jwtTokenConfiguration:
  rsapublicKeyFilePath: ${RSA_PUBLIC_KEY_FILE_PATH:-""}
  rsaprivateKeyFilePath: ${RSA_PRIVATE_KEY_FILE_PATH:-""}
  jwtissuer: ${JWT_ISSUER:-"open-metadata.org"}
  keyId: ${JWT_KEY_ID:-"Gb389a-9f76-gdjs-a92j-0242bk94356"}
```

Note the `RSA_PUBLIC_KEY_FILE_PATH` and `RSA_PRIVATE_KEY_FILE_PATH`, these are env variables made available in the
deployment patch [here][9]. The values were generated using `openssl`:

```bash
openssl genrsa -out private_key.pem 2048
openssl pkcs8 -topk8 -inform PEM -outform DER -in private_key.pem -out private_key.der -nocrypt
openssl rsa -in private_key.pem -pubout -outform DER -out public_key.der
```

Then add these to a k8s secret for consumption by the OM pod. Once configured you should be able to generate a new token
via OM ui.

The token is received from OM through the UI after logging in using the method as described above. Once done, the user
needs to navigate to `Settings > Bots > ingestion-bot` and generate a new token from this ui. You will need to be
using OM +0.11 to generate an infinite token, until then the longest expiry that can be selected is *7 days*.

We set `OM_AUTH_JWT_TOKEN` in the OM pod [here][9]. We also set `AIRFLOW_AUTH_PROVIDER` as such:

```yaml
- name: AIRFLOW_AUTH_PROVIDER
  value: openmetadata
- name: OM_AUTH_JWT_TOKEN
  value: <omitted>
```

[1]: https://docs.open-metadata.org/deploy/deploy-on-kubernetes
[2]: https://github.com/operate-first/apps/tree/master/openmetadata
[3]: https://docs.open-metadata.org/deploy/deploy-on-kubernetes#quickstart
[4]: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes
[5]: https://github.com/operate-first/apps/tree/master/dex/overlays/osc/osc-cl2
[6]: https://github.com/open-metadata/OpenMetadata/issues/5224
[7]: https://docs.open-metadata.org/deploy/secure-openmetadata/google-sso-1
[8]: https://github.com/open-metadata/OpenMetadata/blob/main/conf/openmetadata.yaml
[9]: https://github.com/operate-first/apps/tree/master/openmetadata/overlays/osc/osc-cl2/patches
[10]: https://github.com/operate-first/apps/blob/master/openmetadata/base/openmetadata/configmaps/files/openmetadata.yaml
[11]: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes
[12]: https://docs.open-metadata.org/deployment/security/enable-jwt-tokens#enable-jwt-tokens
