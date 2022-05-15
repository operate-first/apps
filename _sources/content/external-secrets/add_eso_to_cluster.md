# Add External Secrets Operator to an OPF cluster

## Deploy the operator:

Add the [ESO bundle][eso] to the `cluster-scope/overlay/prod/$ENV/$CLUSTER/kustomization.yaml`.

The OLM operator is a helm chart deployer, and lives in the openshift-operators namespace. We use this operator to
deploy the _actual_ operator via an `OperatorConfig` resource, which essentially allows us to specify the helm chart values
via an OCP resource. The bundle above creates the namespace where this resource will live. We deploy this resource
separately via an argocd app.

# Add OperatorConfig resource

> Note: For details on this resource see OLM page for ESO [here][olm]

Add your `OperatorConfig` to the target cluster's overlay found at the root of the `operate-first/apps` repo
here: `operate-first/apps/external-secrets/overlays/$ENV/$CLUSTER`. If you prefer the default config, feel free to just
leverage the one in `base` directory.

# Add the ArgoCD app

Follow the instructions [here][add-app] to add your ArgoCD app. In general we recommend adding it to the
`cluster-managerment` ArgoCD Project.

Commit your changes and create a PR.

[eso]: https://github.com/operate-first/apps/tree/master/cluster-scope/bundles/external-secrets-operator
[olm]: https://operatorhub.io/operator/external-secrets-operator
[add-app]: ../argocd-gitops/add_application.md
