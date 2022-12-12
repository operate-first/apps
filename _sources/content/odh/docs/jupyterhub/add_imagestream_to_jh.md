# Provision a new ImageStream

This doc provides instructions on adding a new imagestream so that it may be available from the JupyterHub ui on Smaug cluster.

## Steps

- Please fork/clone the [operate-first/apps][1] repository
- Navigate to: `kfdefs/base/jupyterhub/notebook-images` , this is where all our imagestreams reside
- Create a new imagestream, use the template below:

```yaml
---
apiVersion: image.openshift.io/v1
kind: ImageStream
metadata:
  labels:
    opendatahub.io/notebook-image: "true"
  annotations:
    opendatahub.io/notebook-image-url: <IMAGE-URL>
    opendatahub.io/notebook-image-name: <IMAGE-NAME>
    opendatahub.io/notebook-image-desc: <IMAGE-Description>
  name: Notebook-template
spec:
  lookupPolicy:
    local: true
  tags:
    - annotations:
        openshift.io/imported-from: <IMAGE-REPO>
      from:
        kind: DockerImage
        name: <IMAGE-REPO>:<IMAGE-TAG>
      importPolicy:
        scheduled: true
      name: <IMAGE-TAG>

```

`<IMAGE-URL> `:  The full github url for this image, e.g. "https://github.com/thoth-station/s2i-minimal-notebook"
`<IMAGE-NAME>`: A short title for this image (appears on the spawner ui)
`<IMAGE-Description>: ` A short description for this image
`<IMAGE-REPO>`: The location where this image resides, e.g. `quay.io/thoth-station/s2i-minimal-notebook`
`<IMAGE-TAG>`:  The image tag e.g. `v0.0.4`

* Name this file according to the image title, and add it to the `notebook-images` folder
* Add this filename to the `kustomization.yaml` to `kfdefs/base/jupyterhub/notebook-images/kustomization.yaml`

Commit your changes and make a PR. Once merged, the imagestream will be deployed by ArgoCD and show up on the JupyterHub spawner UI.

[1]: https://github.com/operate-first/apps
