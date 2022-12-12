# OpenShift Data Foundation (ODF) Runbook

## Prerequisites

You must be a cluster admin on the target OpenShift cluster.

## Identify the problem

- Are existing PVs available?
- If you create a new `PersistentVolumeClaim`, does it bind immediately to a PV?
- Are you able to access existing object buckets?
  - From inside the cluster?
  - From outside the cluster?
- If you create a new `ObjectBucketClaim`, does it bind immediately to
  a new bucket?

If *some* of the above steps work, there is (probably) a software
problem on the cluster. Continue with "Troubleshooting software
problems".

If *none* of the above steps work, it may be a connectivity problem
with the Ceph service; continue with "Troubleshooting Ceph
connectivity".

## Troubleshooting software problems

Generally, troubleshooting problems with the storage subsystem is
going to be very much like troubleshooting issues with any other
application running on OpenShift:

- Look for unhealthy pods (`oc get pod | grep -Evi
  'running|completed'`).

- Inspect the logs of unhealthy pods (`oc logs ...`).

- Inspect events for any errors (`oc get events`).

### Noobaa object storage

To check the status of the Noobaa object storage service, install the
Noobaa CLI from the [releases
page](https://github.com/noobaa/noobaa-operator/releases) and then
run:

```
noobaa -n openshift-storage status
```

This will emit a variety of validation messages on *stderr* and some
status information on *stdout*.  The validation messages look
something like:

```
time="2021-11-23T17:07:41-05:00" level=info msg="CRD Status:"
time="2021-11-23T17:07:41-05:00" level=info msg="✅ Exists: CustomResourceDefinition \"noobaas.noobaa.io\"\n"
[...]
time="2021-11-23T17:07:41-05:00" level=info msg="Operator Status:"
time="2021-11-23T17:07:41-05:00" level=info msg="✅ Exists: Namespace \"openshift-storage\"\n"
time="2021-11-23T17:07:41-05:00" level=info msg="✅ Exists: ServiceAccount \"noobaa\"\n"
time="2021-11-23T17:07:41-05:00" level=info msg="✅ Exists: ServiceAccount \"noobaa-endpoint\"\n"
[...]
time="2021-11-23T17:07:41-05:00" level=info msg="System Wait Ready:"
time="2021-11-23T17:07:41-05:00" level=info msg="✅ System Phase is \"Ready\".\n"
time="2021-11-23T17:07:41-05:00" level=info
time="2021-11-23T17:07:41-05:00" level=info
time="2021-11-23T17:07:41-05:00" level=info msg="System Status:"
time="2021-11-23T17:07:41-05:00" level=info msg="✅ Exists: NooBaa \"noobaa\"\n"
time="2021-11-23T17:07:41-05:00" level=info msg="✅ Exists: StatefulSet \"noobaa-core\"\n"
[...]
time="2021-11-23T17:07:42-05:00" level=info msg="✅ System Phase is \"Ready\"\n"
time="2021-11-23T17:07:42-05:00" level=info msg="✅ Exists:  \"noobaa-admin\"\n"
```

The status information includes various configuration details,
including the external URL for the Noobaa management interface. You
should be able to log into that UI using your OpenShift credentials.

## Troubleshooting Ceph connectivity

You can log into the `rook-ceph-tools` container to run Ceph commands
to diagnose Ceph cluster health and connectivity problems. To log into
the pod:

```
oc -n openshift-storage rsh deploy/rook-ceph-tools
```

If this deployment isn't available, you can enable it by [editing the
`OCSInitialization`
object](https://access.redhat.com/articles/4628891) (accessing that
link requires a Red Hat account).

### Configure credentials

You will
first need to make sure that appropriate credentials exist in
`/etc/ceph`. Look at `/etc/ceph/keyring`; if it only contains...

```
[client.admin]
key = admin-secret
```

...then you will need to add credentials for the user we use to
authenticate to the ceph cluster.  You can obtain the appropriate
credentials by running:


```
oc -n openshift-storage get secret rook-ceph-external-cluster-details -o json |
  jq -r '.data.external_cluster_details|@base64d' |
  jq '.[]|select(.name == "rook-csi-rbd-provisioner")|.data'
```

This will return a JSON block that looks like:

```
{
  "userID": "...",
  "userKey": "..."
}
```

Replace the contents of `/etc/ceph/keyring` with:

```
[client.<value from userID>]
key = <value from userKey>
```

### Check ceph status

Run the `ceph health` command:

```
$ ceph --id provisioner-moc-rbd-1 health
HEALTH_WARN 5 clients failing to respond to cache pressure; 12 nearfull osd(s); 1 pool(s) full; 23 pool(s) nearfull; 1 pgs not deep-scrubbed in time; 19 pgs not scrubbed in time
```

What we care about here is that we get a valid response back from the
Ceph cluster (that is, the command returns information about the
health of the ceph cluster, rather than some sort of communication or
authentication error, etc). In general we don't care about the actual
status value, because it might be in `WARN` or `ERROR` states due to
problems that don't actually impact our usage of the cluster.

### Check RBD access

Ensure that you can list volumes in our RBD pool:

```
$ rbd --id provisioner-moc-rbd-1 --pool moc_rbd_1 ls
```

This should return a list of CSI volumes, like:

```
csi-vol-0b5f9497-40cb-11ec-ac60-0a580a8005aa
csi-vol-15aac588-3cdc-11ec-ac60-0a580a8005aa
csi-vol-16bd1d89-436a-11ec-ac60-0a580a8005aa
...
```

### Check that you can create and delete RBD volumes

Try creating an RBD volume:

```
rbd --id provisioner-moc-rbd-1 --pool moc_rbd_1 create testvol --size 1G
```

And try to delete it:

```
rbd --id provisioner-moc-rbd-1 --pool moc_rbd_1 rm testvol
```
