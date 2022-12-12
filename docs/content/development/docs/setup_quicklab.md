# Quicklab

## Set up a new Quicklab cluster

1. Go to [https://quicklab.upshift.redhat.com/][1] and log in (top right corner)

2. Click **New cluster**

3. Select **openshift4upi** template and a region you like the most, then select the reservation duration, the rest can be left as is:
   ![Select a template][2]

   **Note**: You may need to assign additional worker nodes for your cluster if you are planning to deploy resource intensive workloads.

4. Go to cluster page by clicking on the cluster name in **My clusters** table

5. Once the cluster reaches **Active** state your cluster history should look like this:
   ![Cluster is active for the first time][4]

6. Now click on **New Bundle** button in **Product information** section

7. Select **openshift4upi** bundle. A new form loads. **Opt-in for the `htpasswd` credentials provider.** (You can ignore the warning on top as well, since this is the first install attempt of Openshift on that cluster):
   ![Select a bundle][5]

   **Note**: Pick the latest version of Openshift from the dropdown.

8. Wait for OCP4 to install. After successful installation you should see a cluster history log like this:
   ![Cluster log after OCP4 install][6]

9. Use the link and credentials from the **Cluster Information** section to access your cluster. Verify it contains login information for both `kube:admin` and `quicklab` user.
   ![Cluster information][7]

10. Login as the `kube:admin`, take the value from "Hosts" and port 6443.
    For example:

```sh
oc login upi-0.tcoufaltest.lab.upshift.rdu2.redhat.com:6443
```

[1]: https://quicklab.upshift.redhat.com/
[2]: assets/template_select.png
[4]: assets/cluster_log_1.png
[5]: assets/bundle_select.png
[6]: assets/cluster_log_2.png
[7]: assets/cluster_information.png
