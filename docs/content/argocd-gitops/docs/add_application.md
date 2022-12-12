# Adding ArgoCD Applications

This doc explains how to add ArgoCD Applications declaratively to the `apps` repo.

## Pre-requisites
- You should have [kustomize][2] installed
- You should be familiar with [kustomize overlays][3]
- You should be familiar with what an [ArgoCD application][1] is.
- You or your team should have been on boarded to ArgoCD, and have an ArgoCD project created. If you do not have one please request one for your team by filing this [issue here.][4]

### Add an Application to the Apps repo (declaratively)

All our `clusters` belong to some `environment`. The list of our `environments` can be found [here][5]. Within each `environment` you will find a list of clusters. For example within `moc` environment, you will find clusters `infra` and `smaug`. Pick one such cluster that you would like to deploy to. Let's say you would like to deploy to cluster called `${CLUSTER_NAME}` in environment `${ENV}`. Then follow these steps:

- See ArgoCD Docs for how to create an ArgoCD `Application` [here][1].

- Ensure that the `spec.destination` field in your Argocd `Applicaiton` matches the _cluster name_ as it's stored in ArgoCD. To get this value, you can search the `metadata.name` in the clusters found [here][6]. Or look at any of the other manifests in this repo and find the one that corresponds to `${CLUSTER_NAME}`.

- Ensure that your `spec.project` matches your team's ArgoCD project.

- Add your ArgoCD Application to `argocd/overlays/moc-infra/applications/envs/${ENV}/${CLUSTER_NAME}/{$PROJECT}` where `{$PROJECT}` correlates with your team's project.

- Add this resource's file name to the `resource` field list in `argocd/overlays/moc-infra/applications/envs/${ENV}/${CLUSTER_NAME}/{$PROJECT}/kustomization.yaml` .

[1]: https://argoproj.github.io/argo-cd/operator-manual/declarative-setup/#applications
[2]: https://kubectl.docs.kubernetes.io/installation/kustomize/
[3]: https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/#bases-and-overlays
[4]: https://github.com/operate-first/support/issues/new?assignees=first-operator&labels=kind%2Fonboarding%2Carea%2Fargocd&template=onboarding_argocd.yaml&title=PROJECT%3A+%3Cname%3E
[5]: https://github.com/operate-first/apps/tree/master/argocd/overlays/moc-infra/applications/envs
[6]: https://github.com/operate-first/apps/tree/master/acm/overlays/moc/infra/managedclusters
