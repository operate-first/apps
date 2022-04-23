# Constructing a PR to add an Operator

There are two methods one can follow to add an Operator to a cluster:
1. Install via OLM
1. Manual install

## Install an operator via OLM

Operator Lifecycle Manager (OLM) makes it easy to install and manage Operators on OpenShift clusters.
To install an Operator via OLM, you must make a PR that does the following:

* Create the `Subscription` to the Operator
* Create the corresponding kustomization file
* Pull the resource into the appropriate cluster overlay

Your PR will add the necessary files for the Operator in the base folder and pull the resource in the desired overlays. An explanation of the folder structure can be found [here](folder-doc).

In addition to the `Subscription`, you may also need to add a `Catalog source` or `Operator group`.
Information on `Subscription`, `Catalog source`, and `Operator group` resources can be found [here](openshift-docs).

You can find examples in the `apps` repository of existing `Subscription`, `Operator group`, and `Catalog source` resources [here](apps-operators).
In [this kustomization file](smaug-kustomization) for the `smaug` cluster, you can see an example of how resources are pulled into a cluster.


## Manual installation of an operator

TO-DO

[openshift-docs]: https://docs.openshift.com/container-platform/4.7/operators/understanding/olm/olm-understanding-olm.html
[apps-operators]: https://github.com/operate-first/apps/tree/master/cluster-scope/base/operators.coreos.com
[smaug-kustomization]: https://github.com/operate-first/apps/blob/master/cluster-scope/overlays/prod/moc/smaug/kustomization.yaml
[folder-doc]: https://github.com/operate-first/apps/tree/master/cluster-scope#readme
