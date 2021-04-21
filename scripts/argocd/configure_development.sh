#!/usr/bin/env bash
# Retrieve the ArgoCD route and update the configmap.
ARGOCD_ROUTE=https://$(oc get route argocd-server -n argocd-dev -o jsonpath='{.spec.host}')
oc -n argocd-dev get configmap argocd-cm -o yaml | sed "s#ARGOCD_ROUTE#${ARGOCD_ROUTE}#g" | oc replace -f -

# The default application that's created belongs to the dev project which
# is only accessible by the dev group. So we add you to the group here:
oc adm groups new dev-group
oc adm groups add-users dev-group $(oc whoami)
