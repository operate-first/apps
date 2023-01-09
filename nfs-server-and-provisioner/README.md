# NFS Server and Provisioner deployment on OpenShift - aka RWX for all

> This is copied and adapted from https://github.com/odh-highlander/nfs-server-and-provisioner/tree/7179cfaf02aa72b6291d6f084123313003141e69

For ODH Highlander's shared library to be accessible by all Pods, it has to reside on an RWX volume. RWX stands for Read Write (X)Many, meaning that multiple pods can mount this volume simultaneously.

If you don't have access to an RWX-capable storage class such as the one provided by CephFS trough Rook or OpenShift Data Foundation, you can follow this recipe to deploy an NFS server as well as a provisioner that will give you access to this type of volume.

The provisioner will use a single PVC where it will create export folders that will be presented as RWX volumes by the NFS Server.

This solution is based on [this project](https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner), with some adaptations and modifications for OpenShift, as well as a special recipe to share the same volume across workspaces!

## Deployment

### Prerequisites

- An OpenShift cluster. This deployment has been tested on OpenShift 4.10.
- A cluster admin account.

### Deployment steps

NOTE: all files mentioned here are in the [deploy](./deploy) folder in this repo.

1. Log onto OpenShift with your cluster admin account.
2. Create a project where the provisioner will be deployed. In these instructions and the provided YAML files, the project name is `nfs-provisioner`. Modify the files accordingly if you choose a different name. All subsequent commands are made inside this project.

    ```bash
    oc new-project nfs-provisioner
    ```

3. Create a PVC named `export-pv-claim`. This volume will be used by the provisioner to create spaces (in fact export folders) when you create/request a new RWX PVC using the corresponding StorageClass. Size it well, as it will hold all subsequent PVC. You will find an example `export-pv-claim.yaml` in the deploy folder. It has a base size of 500GB, and uses the gp2 StorageClass from Amazon. Modify the size and the StorageClass according to what is available on your cluster.

    ```bash
    oc apply -f export-pv-claim.yaml
    ```

4. Deploy the file `scc.yaml` to create the custom SecurityContextConstraints:

    ```bash
    oc apply -f scc.yaml
    ```

5. Deploy the file `rbac.yaml` to create Roles and RoleBindings:

    ```bash
    oc apply -f rbac.yaml
    ```

6. Deploy the file `deployment.yaml` to create the provisioner and server Deployment:

    ```bash
    oc apply -f deployment.yaml
    ```

7. Deploy the file `class.yaml` to create the corresponding StorageClass:

    ```bash
    oc apply -f class.yaml
    ```

## Usage

You now have a StorageClass called `nfs-provisioner` that you can use to create a PVC in RWX mode. The storage space will be taken out of the main PVC you created to deploy the provisioner.

In the [Usage](./usage/) folder you will find different YAML files to test the installation.

1. In a new test project, create a basic PVC of 1Mi from the new StorageClass `nfs-provisioner`:

    ```bash
    oc apply -f claim.yaml
    ```

2. Create a first pod that will keep running until deleted:

    ```bash
    oc apply -f pod-1.yaml
    ```

3. Create a second pod that will also keep running until deleted:

    ```bash
    oc apply -f pod-2.yaml
    ```

4. Log into Pod-1 (you can use the Terminal view from the OpenShift console), switch to the `/mnt` folder, and create a new file:

    ```bash
    cd /mnt
    echo "Test" > test.txt
    ```

5. Log into Pod-2 (you can use the Terminal view from the OpenShift console), switch to the `/mnt` folder, and view the file:

    ```bash
    cd /mnt
    cat test.txt
    ```

You should see `Test` as the command output!
You can now switch back and forth and experiment as you like. The same PVC is mounted and accessible simultaneously from both Pod. Or any other Pod you want.

## Sharing a volume across namespaces

The trick is in fact quite simple. As at the heart of this a Persistent Volume is in fact pointing to a specific export on the NFS server, you can create another PV that will simply point to the same export. You can then create another PVC in a new namespace that you bind to the "clone" of the original PV.

1. Following our previous usage example, edit the PV that was created with the `shared-folder` PVC. Change the field `persistentVolumeReclaimPolicy` from `Delete` to `Retain`.

2. Copy the YAML definition of the PV and clean all non-essential information, like `annotations`, `finalizers`, `managedFields`, `claimRef` and `status`. Change the name of the PV. Beware, it must still to be unique in the cluster. So for example, just add `-clone1` to the end. You should have something like this:

    ```yaml
    kind: PersistentVolume
    apiVersion: v1
    metadata:
        name: pvc-eb3508d9-bbb1-438b-a7d0-988dfcaca13d-clone1
    spec:
        capacity:
            storage: 1Mi
        nfs:
            server: 172.30.83.53
            path: /export/pvc-eb3508d9-bbb1-438b-a7d0-988dfcaca13d
        accessModes:
            - ReadWriteMany
        persistentVolumeReclaimPolicy: Retain
        storageClassName: nfs-provisioner
        mountOptions:
            - vers=4.1
        volumeMode: Filesystem
    ```

    IMPORTANT: Do not change the capacity of the PV!

3. Create the new PV with the YAML file.
4. Switch to the project where you want to use the volume, and create a new PVC that will use the previously created PV. In this example, we are using a project named `clone`.

    ```yaml
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
        name: shared-folder
        namespace: clone
    spec:
        accessModes:
           - ReadWriteMany
        resources:
            requests:
                storage: 1Mi
        volumeName: pvc-eb3508d9-bbb1-438b-a7d0-988dfcaca13d-clone1
        storageClassName: nfs-provisioner
        volumeMode: Filesystem
    accessModes:
        - ReadWriteMany
    capacity:
        storage: 1Mi
    ```

5. To verify that this new PVC is using the same volume, you can again create a Pod in your project.

    ```bash
    oc apply -f pod-1.yaml -n clone
    ```

6. Using the terminal in this new pod, you can verify that you have access to the same file.

    ```bash
    cd /mnt
    cat test.txt
    ```

To properly delete a shared volume like this:

- Delete the PVCs in all the projects where you have "cloned" the volume except for the original one.
- Delete the now unbound corresponding PVs. The `Retain` policy will keep the volume.
- On the original PV, change the `persistentVolumeReclaimPolicy` back to `Delete`.
- Delete the original PVC.
