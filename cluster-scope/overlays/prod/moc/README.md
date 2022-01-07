# MOC environment

## Managed clusters

The following clusters are managed by the overlays in this directory

- [Infra](infra) - Cluster for management via ACM and ArgoCD
  - [Openshift Console](https://console-openshift-console.apps.moc-infra.massopen.cloud/)
  - [ArgoCD](https://argocd-server-argocd.apps.moc-infra.massopen.cloud/)
  - [Advanced Cluster Management for Kubernetes - Multicloud Console](https://multicloud-console.apps.moc-infra.massopen.cloud/)
- [Curator](curator) - Cluster for the Curator project
  - [Openshift Console](https://console-openshift-console.apps.curator.massopen.cloud/)

## Secret management

Secrets in this environment are encrypted via these secrets. In order to modify an encrypted resource, you need to own a private key for any of the keys listed below + all the public keys.

- Operate First key: [`0508677DD04952D06A943D5B4DC4116D360E3276`](https://keys.openpgp.org/search?q=0508677DD04952D06A943D5B4DC4116D360E3276)
- Lars Kellogg-Stedman: [`5B2E9490ED4F7BB379EC93C17BF065CD97112F06`](https://keys.openpgp.org/search?q=5B2E9490ED4F7BB379EC93C17BF065CD97112F06)
- Ilana Polonsky: [`3625572E2E3C694CB19911FFB727FBE237CEADAC`](https://keys.openpgp.org/search?q=3625572E2E3C694CB19911FFB727FBE237CEADAC)
- Naved Ansari: [`B27ED6FAF92F28FA805451F33F5CA0E2A1824018`](https://keys.openpgp.org/search?q=B27ED6FAF92F28FA805451F33F5CA0E2A1824018)

## Team specific keys

Please import these public GPG keys in order to manage resources that belongs to specific teams:

- Apicurio team: [`4B6A81C7D1711864408480CEC37C8EDF9301474C`](https://keys.openpgp.org/search?q=4B6A81C7D1711864408480CEC37C8EDF9301474C)
- Lab CI-CD team: [`169131BA05F8885E6691A91AD7CFA8E51DA86A14`](https://keys.openpgp.org/search?q=169131BA05F8885E6691A91AD7CFA8E51DA86A14)

Preferred key hosting: keys.openpgp.org, keys.gnupg.net
