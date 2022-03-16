# Set up on-cluster PersistentVolumes storage using NFS on local node

Bare Openshift cluster installations, like for example Quicklab's Openshift 4 UPI clusters may lack persistent volume setup. This guide will help you set it up.

Please verify that your cluster really lacks `pv`s:

1. Login as a cluster admin (login details can be found through the `copy login command` at the drop down menu under the username at OpenShift console.)
2. Lookup available `PersistentVolume` resources:

   ```bash
   $ oc get pv
   No resources found
   ```

If there are no `PersistentVolume`s available please continue and follow this guide. We're gonna set up NFS server on the cluster node and show Openshift how to connect to it.

Note: This guide will lead you through the process of setting up PVs, which use the deprecated `Recycle` reclaim policy. This makes the `PersistentVolume` available again as soon as the `PersistentVolumeClaim` resource is terminated and removed. However the data are left on the NFS share untouched. While this is suitable for development purposes, be advised that old data (from previous mounts) will be still available on the volume. Please consult [Kubernetes docs](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaiming) for other options.

## Manual steps

See automated Ansible playbook bellow for easier-to-use provisioning

### Prepare remote host

1. SSH to the Quicklab node, and become superuser:

   ```sh
   curl https://gitlab.cee.redhat.com/cee_ops/quicklab/raw/master/docs/quicklab.key --output ~/.ssh/quicklab.key
   chmod 600 ~/.ssh/quicklab.key
   ssh -i ~/.ssh/quicklab.key -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no" quicklab@HOST

   # On HOST
   sudo su -
   ```

2. Install `nfs-utils` package

   ```sh
   yum install nfs-utils
   ```

3. Create exported directories (for example in `/mnt/nfs`) and set ownership and permissions

   ```sh
   mkdir -p /mnt/nfs/A ...
   chown nfsnobody:nfsnobody /mnt/nfs/A
   chmod 0777 /mnt/nfs/A
   ```

4. Populate `/etc/exports` file referencing directories from previous step to be accessible from your nodes as read,write:

   ```txt
    /mnt/nfs/A node1(rw) node2(rw) ...
    ...
   ```
   where node1, node2 are respective nodes from OpenShift console. It can be accessed by `oc get nodes` command in the terminal. Once you access the names of nodes, you can add there name in the above format in `/etc/exports` file. 

5. Allow NFS in firewall

   ```sh
   firewall-cmd --permanent --add-service mountd
   firewall-cmd --permanent --add-service rpc-bind
   firewall-cmd --permanent --add-service nfs
   firewall-cmd --reload
   ```

6. Start and enable NFS service

   ```sh
   systemctl enable --now nfs-server
   ```

### Add PersistentVolumes to Openshift cluster

Login as a cluster admin and create a `PersistentVolume` resource for each network share using this manifest:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: NAME # Unique name
spec:
  capacity:
    storage: CAPACITY # Keep in mind the total max size, the Quicklab host has a disk size of 20Gi total (usually ~15Gi of available and usable space)
  accessModes:
    - ReadWriteOnce
  nfs:
    path: /mnt/nfs/A # Path to the NFS share on the server
    server: HOST_IP # Not a hostname
  persistentVolumeReclaimPolicy: Recycle
```

## Using Ansible

To avoid all the hustle with manual setup, we can use an Ansible playbook [`playbook.yaml`](playbook.yaml).

### Setup

Please install Ansible and some additional collections from Ansible Galaxy needed by this playbook: [ansible.posix](https://galaxy.ansible.com/ansible/posix) for `firewalld` module and [kubernetes.core](https://galaxy.ansible.com/kubernetes/core) for `k8s` module using the `requirements.yaml` file.

```bash
$ ansible-galaxy collection install -r requirements.yaml
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Installing 'kubernetes.core:2.2.3' to '/home/tcoufal/.ansible/collections/ansible_collections/kubernetes/core'
Downloading https://galaxy.ansible.com/download/kubernetes-core-2.2.3.tar.gz to /home/tcoufal/.ansible/tmp/ansible-local-4073sl0jhj1j/tmp9x9w4i_0
kubernetes.core (2.2.3) was installed successfully
Installing 'ansible.posix:1.3.0' to '/home/tcoufal/.ansible/collections/ansible_collections/ansible/posix'
Downloading https://galaxy.ansible.com/download/ansible-posix-1.3.0.tar.gz to /home/tcoufal/.ansible/tmp/ansible-local-4073sl0jhj1j/tmp9x9w4i_0
ansible.posix (1.3.0) was installed successfully
```

Additionally please login to your Quicklab cluster via `oc login` as a cluster admin.

### Configuration

Please view and modify the `env.yaml` file (or create additional variable files, and select it before executing playbook via `vars_file` variable)

Example environment file:

```yaml
quicklab_host: "upi-0.tcoufaldev.lab.upshift.rdu2.redhat.com"

pv_count_per_size:
  1Gi: 6
  2Gi: 2
  5Gi: 1
```

- `quicklab_host` - Points to one of the "Hosts" from your Quicklab Cluster info tab
- `pv_count_per_size` - Defines PV counts in relation to maximal allocable sizes map:
  - Use the target PV size as a key (follow GO/Kubernetes notation)
  - Use volume count for that key "size" as the value
  - Keep in mind the total size sum(key\*value for key,value in pv_count_per_size.items()) < Disk size of the Quicklab instance (usually ~15Gi of available space)

### Run the playbook

Run the `playbook.yaml` (if you created a new environment file and you'd like to use other than default `env.yaml`, please specify the file via `-e vars_file=any-filename.yaml`)

```bash
$ ansible-playbook playbook.yaml
```

<details>
<summary>Click to expand output</summary>

```bash
PLAY [Dynamically create Quicklab host in Ansible] **********************************************************************

TASK [Gathering Facts] **************************************************************************************************
ok: [localhost]

TASK [Load variables file] **********************************************************************************************
ok: [localhost]

TASK [Preprocess the PV count per size map to a flat list] **************************************************************
ok: [localhost]

TASK [Install python dependency] ****************************************************************************************
changed: [localhost]

TASK [Fetch Quicklab certificate] ***************************************************************************************
ok: [localhost]

TASK [Adding host] ******************************************************************************************************
changed: [localhost]

TASK [Get available Openshift nodes] ************************************************************************************
ok: [localhost]

TASK [Preprocess nodes k8s resource response to list of IPs] ************************************************************
ok: [localhost]

PLAY [Setup NFS on Openshift host] **************************************************************************************

TASK [Gathering Facts] **************************************************************************************************
ok: [quicklab]

TASK [Copy localhost variables for easier access] ***********************************************************************
ok: [quicklab]

TASK [Install the NFS server] *******************************************************************************************
ok: [quicklab]

TASK [Create export dirs] ***********************************************************************************************
changed: [quicklab] => (item=['1Gi', 0])
changed: [quicklab] => (item=['1Gi', 1])
changed: [quicklab] => (item=['1Gi', 2])
changed: [quicklab] => (item=['1Gi', 3])
changed: [quicklab] => (item=['1Gi', 4])
changed: [quicklab] => (item=['1Gi', 5])
changed: [quicklab] => (item=['2Gi', 0])
changed: [quicklab] => (item=['2Gi', 1])
changed: [quicklab] => (item=['5Gi', 0])

TASK [Populate /etc/exports file] ***************************************************************************************
changed: [quicklab]

TASK [Allow services in firewall] ***************************************************************************************
changed: [quicklab] => (item=nfs)
changed: [quicklab] => (item=rpc-bind)
changed: [quicklab] => (item=mountd)

TASK [Reload firewall] **************************************************************************************************
changed: [quicklab]

TASK [Enable and start NFS server] **************************************************************************************
changed: [quicklab]

TASK [Reload exports when the server was already started] ***************************************************************
skipping: [quicklab]

PLAY [Create PersistentVolumes in OpenShift] ****************************************************************************

TASK [Gathering Facts] **************************************************************************************************
ok: [localhost]

TASK [Find IPv4 of the host] ********************************************************************************************
ok: [localhost]

TASK [Create PersistentVolume resource] *********************************************************************************
changed: [localhost] => (item=['1Gi', 0])
changed: [localhost] => (item=['1Gi', 1])
changed: [localhost] => (item=['1Gi', 2])
changed: [localhost] => (item=['1Gi', 3])
changed: [localhost] => (item=['1Gi', 4])
changed: [localhost] => (item=['1Gi', 5])
changed: [localhost] => (item=['2Gi', 0])
changed: [localhost] => (item=['2Gi', 1])
changed: [localhost] => (item=['5Gi', 0])

PLAY RECAP **************************************************************************************************************
localhost                  : ok=10   changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
quicklab                   : ok=8    changed=5    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

</details>
