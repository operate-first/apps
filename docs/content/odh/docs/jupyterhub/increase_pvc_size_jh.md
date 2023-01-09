# Increase PVC size for JupyterHub

When you first log in to JupyterHub, a PVC is automatically provisioned for you on the Smaug cluster. This PVC however, is not tracked in git, so we will need to first add it to git, before we increase the size. If your PVC has already been added to git (likely because you have had its size increased before already), then you can skip the creation portion.

## Add pvc to GitHub

Create a PVC in `kfdefs/overlays/moc/smaug/opf-jupyterhub/pvcs`, use the following syntax to name it: `<your_github_handle>.yaml`. Populate this file as follows:

```yaml
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  annotations:
    hub.jupyter.org/username: <YOUR_OCP_USERNAME> # Your github user handle
  name: name
  labels:
    app: jupyterhub
    component: singleuser-storage
spec:
  resources:
    requests:
      storage: <YOUR_PREFERRED_SIZE> # e.g. 10Gi

```

> Note: if your PVC already exists, simply increase the `spec.resources.requests.storage` value as needed

Add this filename to the `kustomization.yaml` located at: `kfdefs/overlays/moc/smaug/opf-jupyterhub/pvcs/kustomization.yaml`

Commit your changes and make a PR, once merged ArgoCD will deploy the changes and you should then see an increase in your storage. You can verify your changes by following the instructions [here][1].

[1]: analyze_storage.md
