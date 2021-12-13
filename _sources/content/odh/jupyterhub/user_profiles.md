# Managing user profiles

This document should help you manage the user profiles for ODH users.

The following steps serves as a guide for maintenance on user profiles for ODH JupyterHub.

## Prerequisites

You will need pre-requisite tools to follow along with this doc, please do one of the following:

- Install our [toolbox][1] to have the developer setup ready automatically for you.
- Install the tools manually. You'll need [kustomize][2], [sops][3] and [ksops][4].

Please fork/clone the [operate-first/apps][5] repository.

## JupyterHub user profiles and HW quota

JupyterHub userprofiles are managed [here][6]. These are amendments to the configmaps that are pulled from the [odh-manifests repo][7]. They are managed by ODH operator. Any new configmaps ought to be added [here][8], so they may be managed by ArgoCD.

[1]: https://github.com/operate-first/toolbox
[2]: https://kustomize.io/
[3]: https://github.com/mozilla/sops
[4]: https://github.com/viaduct-ai/kustomize-sops
[5]: https://github.com/operate-first/apps
[6]: https://github.com/operate-first/apps/tree/master/odh-manifests/smaug/jupyterhub/base
[7]: https://github.com/opendatahub-io/odh-manifests
[8]: https://github.com/operate-first/apps/tree/master/kfdefs/overlays/moc/smaug/opf-jupyterhub
