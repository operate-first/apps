# Managing user profiles

This document should help you manage the user profiles for ODH users.

The following steps serves as a guide for maintenance on user profiles for ODH JupyterHub.

## Prerequisites

You will need pre-requisite tools to follow along with this doc, please do one of the following:

- Install our [toolbox](https://github.com/operate-first/toolbox) to have the developer setup ready automatically for you.
- Install the tools manually. You'll need [kustomize](https://kustomize.io/), [sops](https://github.com/mozilla/sops) and [ksops](https://github.com/viaduct-ai/kustomize-sops).

Please fork/clone the [operate-first/apps](https://github.com/operate-first/apps) repository.

## JupyterHub user profiles and HW quota

JupyterHub userprofiles are managed [here](https://github.com/operate-first/apps/tree/master/odh-manifests/smaug/jupyterhub/base). These are amendments to the configmaps that are pulled from the [odh-manifests repo](https://github.com/opendatahub-io/odh-manifests). They are managed by ODH operator. Any new configmaps ought to be added [here](https://github.com/operate-first/apps/tree/master/kfdefs/overlays/moc/smaug/opf-jupyterhub), so they may be managed by ArgoCD.
