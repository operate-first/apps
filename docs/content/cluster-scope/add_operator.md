#  Adding an Operator to a Cluster

There are two methods one can follow to add an Operator to a cluster:
1. Install via Operator Lifecycle Manager (OLM)
1. Manual install

Installing via OLM is easier and often the preferred method of installation, but there are a few things to consider when choosing this install method. In order to install your operator via OLM you need to find it in either the [k8s community operators list][1] or [ocp community operators list][2]. If your operator is available in a different catalog source you will need to check if said catalog source is available on the target cluster.

## Install an operator via OLM

### Pre-requisites
* Basic understanding of k8s and OCP/OLM
* Basic knowledge of Git and [Kustomize][13]
* Check if an operator bundle already exists for the desired operator [here][3] (if it does exist you can probably just include this bundle in the desired cluster overlay)
* Know the name of the operator and its target version, catalogSource, and operatorChannel and what operator channel need to be deployed
* Know the scope of the operator, is it global or namespace scoped? (NOTE: for non-global operators you will also need to add an `operatorGroup` in the target namespaces, see [here][4] for more info). Global operators are installed to the openshift-operators namespace which already has an `operatorGroup`.
    * To create a namespace for a non-global operator:
        * Navigate to: apps/cluster-scope/base/core/namespaces/
        * Create a directory for the new namespace and include the namespace.yaml and the associated kustomization file

OLM makes it easy to install and manage Operators on OpenShift clusters.
To install an Operator via OLM, you must do the following:

1. Clone the [apps repo][5]
1. Navigate to apps/cluster-scope/base/operators.coreos.com/subscriptions/
    * Create a directory for the new operator and include the subcription.yaml (for examples of what subscription.yaml files look like take a look at the subscription.yaml files in the directories under apps/cluster-scope/base/operators.coreos.com/subscriptions/). Also include the associated kustomization.yaml file.
        * Keep installPlanApproval: Automatic
        * Avoid adding a starting CSV, since we keep automating install plans
        * Always choose the most stable version unless there's a specific reason not to
        * For more info relating to subcriptions see [here][6]
    * If you are unsure how to structure your `subscription`, we recommend searching for this operator's `PackageManifest` resource for the required information above (e.g. `oc get packagemanifest argocd-operator -o yaml`). More generally, you can run `oc get packagemanifest` if you're unsure of the operator name. You can search for all of this in the target cluster, or a dev cluster if you do not have sufficient access. Another method is to use a dev cluster and install this operator and retrieve the relevant fields from the `subscription` resource that's created.
1. In the event that you need to add a `Catalog source` (if you're deploying an operator using a `catalogSource` not installed yet on the cluster) or `operatorGroup`, you'll also need to add these at the cluster-scope level
    * To add an `catalogSource`:
        * Navigate to: apps/cluster-scope/base/operators.coreos.com/catalogsources/
        * Create a directory with for your `catalogSource` and include your operatorGroup.yaml and associated kustomization file
            * The namespace should be either the openshift-marketplace namespace or the new operator namespace
    * To add an `operatorGroup`:
        * Navigate to: apps/cluster-scope/base/operators.coreos.com/operatorgroups/
        * Create a directory with for your `operatorGroup` and include your operatorGroup.yaml and associated kustomization file
1. Pull the subscription (and if applicable `operatorGroup`, `catalogSource`, `namespace`) into the appropriate cluster overlay
    * (NOTE: If you are adding more than one of the resources above you need to create a resource bundle for the operator)
        * To add a resource bundle navigate to apps/cluster-scope/base/bundles/
        * Create a directory for the operator and add a kustomization.yaml file that includes all the resources
        * Add this bundle into the appropriate cluster overlay
1. Open a pull request in the [apps repo][5] with your changes

You can find examples in the `apps` repository of existing `Subscription`, `Operator group`, and `Catalog source` resources [here][7].
In [this kustomization file][8] for the `smaug` cluster, you can see an example of how resources are pulled into a cluster.

An explanation of the OPF folder structure can be found [here][9].

## Manual installation of an operator

If there does not exist an operator that can be deployed via OLM or if there is any other reason you cannot deploy the operator via OLM, then you'll need to deploy it manually using argoCD.

### Pre-requisites
* Basic understanding of k8s, argoCD, and OCP
* Basic knowledge of git and kustomize
* Have all the required manifests to deploy the operator via argoCD
* know the namespace the operator needs to be deployed

To manually deploy an operator:

1. Clone the [apps repo][5]
1. Add all required cluster scoped manifests according to the [folder-structure][12]
    * Be sure to first check if a resource bundle exists for the operator by browsing apps/cluster-scope/bundles/
        * If one does exist you will simply need to pull this bundle into the desired cluster overlay and move to step 3
    * Common cluster-scope resources include `clusterRole`, `clusterRoleBinding`, `customResourceDefinition`, etc
        * Navigate to apps/cluster-scope/base/
        * Add the necessary <resource>.yaml files and the associated kustomization.yaml files for each, under the appropriate directory according to the resource type
        * Pull the resource(s) into the appropriate cluster overlay (NOTE: If you are adding more than one of the resources above you need to create a resource bundle for the operator)
            * To add a resource bundle navigate to apps/cluster-scope/bundles/
            * Create a directory for the operator and add a kustomization.yaml file that includes all the resources
            * Add this bundle into the appropriate cluster overlay
1. Add all required namespace scoped manifests in a new directory under [apps][5]
    * The structure for adding namespace scoped manifests is `apps/<operator-name>/overlays/$env/$cluster/kustomization.yaml` (NOTE: see examples from other deployments under apps/ for more clarity)
1. Create an argoCD application under the desired cluster overlay and env [here][10]. See also [add_application][11]
1. Open a pull request in the [apps repo][5] with your changes

[1]: https://github.com/k8s-operatorhub/community-operators/tree/main/operators
[2]: https://github.com/redhat-openshift-ecosystem/community-operators-prod/tree/main/operators
[3]: https://github.com/operate-first/apps/tree/master/cluster-scope/bundles
[4]: https://docs.openshift.com/container-platform/4.9/operators/understanding/olm/olm-understanding-operatorgroups.html
[5]: https://github.com/operate-first/apps
[6]: https://olm.operatorframework.io/docs/concepts/crds/subscription/
[7]: https://github.com/operate-first/apps/tree/master/cluster-scope/base/operators.coreos.com
[8]: https://github.com/operate-first/apps/blob/master/cluster-scope/overlays/prod/moc/smaug/kustomization.yaml
[9]: https://github.com/operate-first/apps/tree/master/cluster-scope#readme
[10]: https://github.com/operate-first/apps/tree/master/argocd/overlays
[11]: https://github.com/operate-first/apps/blob/master/docs/content/argocd-gitops/add_application.md
[12]: https://github.com/operate-first/apps/tree/master/cluster-scope#application-folder-structure
[13]: https://kustomize.io/
