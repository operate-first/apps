# Managing user profiles

This document should help you manage the user profiles for ODH users.

The following steps serves as a guide for maintenance on user profiles for ODH JupyterHub.

## Prerequisites

You will need pre-requisite tools to follow along with this doc, please do one of the following:

- You'll need [kustomize][1] to test your builds.
- Git

Please fork/clone the [operate-first/apps][2] repository.

## JupyterHub user profiles

JupyterHub user profiles are managed [here][3]. Look for files named `jupyterhub-singleuser-profiles-*`.

[1]: https://kustomize.io/
[2]: https://github.com/operate-first/apps
[3]: https://github.com/operate-first/odh-manifests/tree/smaug-v1.1.1/jupyterhub/jupyterhub/base
