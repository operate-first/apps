# Adding Cluster Resources

To add a cluster resource to a cluster, you will need to know the `${ENVIRONMENT}` and `${CLUSTER}` you would like to add this resource to.

You will also need the url to the raw file (e.g. a raw file from github) or a path to the resource manifest on your local file system.

Once you have that, you can use the following script from this repo to add this resource:

```bash
# from the root of this repo
$ ./scripts/add_cluster_resource.sh ${ENVIRONMENT} ${CLUSTER} -f ${PATH}

# OR

$ ./scripts/add_cluster_resource.sh ${ENVIRONMENT} ${CLUSTER} -u ${URL}
```

Example:

```bash
$ ./scripts/add_cluster_resource.sh moc zero -f /path/to/file.yaml
```
