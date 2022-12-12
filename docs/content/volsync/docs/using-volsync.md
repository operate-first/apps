# Using Volsync to back up persistent volumes
The Volsync operator supports backing up your project's persistent volumes.

Volsync is currently deployed and available on the Smaug cluster.

You can find the documentation for Volsync usage [here](https://volsync.readthedocs.io/en/stable/usage/index.html).

Anyone with the view role is granted view-only access to ReplicationSource and ReplicationDestination objects as well as VolumeSnapshots in order to monitor data replication.
Anyone with the edit role has full control of ReplicationSource and ReplicationDestination objects.
They also have the ability to view VolumeSnapshots to promote destination snapshots into usable PVCs.
The edit role allows users not only to monitor, but also to manage data replication.

For more information on RBAC permissions in Volsync, please visit the Volsync documentation [here](https://volsync.readthedocs.io/en/latest/installation/rbac.html).

## Links and Resources
- [Volsync docs](https://volsync.readthedocs.io/en/stable/index.html)
- [Volsync github](https://github.com/backube/volsync)
