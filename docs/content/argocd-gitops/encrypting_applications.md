# How to encrypt apps in this repo

We use SOPS to encrypt our secrets and other k8s/openshift resources in vcs. We use a Kustomize plugin called KSOPs to allow us to use sops with kustomize builds. We include KSOPs with ArgoCD and import our keys so that we can also have ArgoCD deploy manifests that are encrypted via sops in vcs. Read more about how to install and use KSOPs and SOPS [here](https://github.com/operate-first/continuous-deployment/blob/master/docs/manage_your_app_secrets.md)

# GPG Key
In the link above you will require a public fingerprint to include in your sops.yaml, this comes from a gpg key we use for all our apps in this repo and can be found [here](https://keys.openpgp.org/search?q=aicoe-operate-first%40redhat.com).

If you are an active contributor and require the private key, please make an issue or reach out to another active contributor/maintainer for it. Be prepared to provide your own public key so that we may send it to you securely.
