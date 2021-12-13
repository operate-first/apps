# Analyze Storage for a Notebook

This doc aims to answer commonly asked questions pertaining to investigating/analyzing one's JupyterHub notebook server storage.

## How can I know how much JupyterHub local storage (PVC) I have?

You can do this using one of 2 ways:

* Using Grafana: Visit our dashboard for Jupyterhub found [here][1]. Select the `openshift-monitoring` datasource, and your OCP `user` from the dropdown. Then the amount of free storage in my pvc can be assessed by inspecting the used/total space panel.
* Start your notebook server, go into your `terminal`, type the command `df -h` , the amount of free storage in your pvc should be listed under "Available" column, mounted on /opt/app-root/src


## I want to know what is consuming most of the space on my PVC

Start your notebook server, go into your `terminal`, type the following command:

```bash
du -h --max-depth=2 . | sort -h
```

This should display a list of folders on your PVC sorted by their size.


## How can I cleanup my `Pipenv` cache?

Simply delete the folder named `.cache/pipenv`.

[1]: https://grafana.operate-first.cloud/d/fuJBFErMz/jupyterhub-user-perspective?orgId=1
