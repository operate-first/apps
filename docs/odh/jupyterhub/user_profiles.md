# Managing user profiles

This document should help you manage the user profiles for ODH users.

The following steps serves as a guide for maintenance on user profiles for ODH JupyterHub and global ceph buckets hosted on MOC clusters.

## Prerequisites

You will need pre-requisite tools to follow along with this doc, please do one of the following:

- Install our [toolbox](https://github.com/operate-first/toolbox) to have the developer setup ready automatically for you.
- Install the tools manually. You'll need [kustomize](https://kustomize.io/), [sops](https://github.com/mozilla/sops) and [ksops](https://github.com/viaduct-ai/kustomize-sops).

Please fork/clone the [operate-first/apps](https://github.com/operate-first/apps) repository. **During this whole setup, we'll be working within this repository.**

## JupyterHub user profiles and HW quota

TBD, probably maintained within `apps` repo at `odh/overlays/TARGET_CLUSTER/jupyterhub/`?

## Claiming Ceph bucket

TBD, probably a separate application in `apps` repo?
