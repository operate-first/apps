#!/usr/bin/env bash
# Retrieve the ArgoCD route and update the configmap.
ARGOCD_ROUTE=https://$(oc get route argocd-server -n argocd -o jsonpath='{.spec.host}')
oc -n argocd get configmap argocd-cm -o yaml | sed "s#ARGOCD_ROUTE#${ARGOCD_ROUTE}#g" | oc replace -f -
