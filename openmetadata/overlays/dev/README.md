## Dev Openmetadata deployment

#### Prerequisites
- A namespace called `openmetadata`, you can change this namespace by updating it in the kustomization
  (or specifying an `-n` flag when applying.)
- Logged in to target OCP cluster via `oc`
- Project admin on target namespace
- Cluster should have storage set up (i.e. you can create PVC's and have a default storage class)


#### To deploy:

```bash
git clone https://github.com/operate-first/apps.git
cd apps/openmetadata/overlays/dev
```

Here you will find all the dev manifests. In the `dev/patches` directory, replace any instance of `$YOUR_NAMESPACE` with
your target namespace. Or just run the following command:

```
# substitute <add-your-namespace-here> with your target namspace
kustomize build . | sed --expression='s/$YOUR_NAMESPACE/<add-your-namespace-here>/g' | oc apply -f -
```

This will deploy all the dependencies and Openmetadata. Since we're not doing these one by one, you'll probably see a
lot of pods crashing initially, but once Elasticsearch / Mysql are in a ready state then the airflow pods should start
running without issues. Wait for all pods to be ready before attempting to use Openmetadata.

There are 2 pods "openmetadata-test-*" and "openmetadata-dependency-test-*", it is fine if they fail before their
respective pods are starting up, but these pods should succeed once everything else is in a running state. You can try
recreating them to retry the tests to see them succeed.

Note also that it is normal for airflow-web to take a while to ready up.

Airflow credentials are admin/admin.
