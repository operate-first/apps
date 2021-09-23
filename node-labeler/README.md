# Node Labeler

Our cluster is built from machines that aren't completely identical.
In particular, they don't all share interface names. Looking at the
primary interface on our worker nodes, we see:

- eno1
- enp4s0f0np0
- enp5s0f0np0
- enp65s0f0np0
- enp65s0f1np1
- ens2f0

When adding VLAN interfaces to these systems, we need to know the name
of the primary interface. This `node-labeler` application runs as a
`DaemonSet`, with one pod on each node running in the host network
namespace. A very simple shell script looks up the primary interface
on the node (by inspecting the output of `ip route` for the default
route), and uses that information to label the node with the
`massopen.cloud/primary-interface` label.
