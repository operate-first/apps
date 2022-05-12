# Prometheus

Prometheus is part of the alerting stack that we use in Operate-First.

# Adding or removing alerts

To add alerts there are 2 modifications need to happen.

Firstly the alert itself must be constructed through a `PrometheusRule` file. Typically these files live alongside the application that they are creating the alerts for. Examples of this can be seen for [argocd in MOC-Infra](https://github.com/operate-first/apps/blob/master/argocd/overlays/moc-infra/alerts.yaml), [jupyterhub on Smuag](https://github.com/operate-first/apps/blob/master/kfdefs/overlays/moc/smaug/jupyterhub/alerts.yaml), and the [blackbox exporter on Smuag](https://github.com/operate-first/apps/blob/master/grafana/overlays/moc/smaug/blackbox-exporter/recording-rules.yaml). It is important to note that these `PrometheusRule` files are defined per overlay. For more information on creating the alerts themselves, refer to the [prometheus docs]()

Secondly, we must tell the alertmanager-github-receiver how to route the alerts. This can be done by modifying the [alertmanager-main-secret](https://github.com/operate-first/apps/blob/master/cluster-scope/overlays/prod/common/alertmanager-main-secret.yaml) file. This defines which alerts should be forwarded to which receivers. To remove or silence an alert, the entry can either be deleted, or the receiver can be swapped to the `"null"` value, which will silence it.

# Adding new alertmanager github receiver instances

Adding new receivers have 2 parts. Firstly create an overlay in the [alertmanager directory](https://github.com/operate-first/apps/tree/master/alertreceiver/overlays), to create a new deployment of base and patching in the necesary value. An example of this for MOC/Smaug can be seen [here](https://github.com/operate-first/apps/blob/master/alertreceiver/overlays/moc/smaug/kustomization.yaml). Secondly, the receiver needs to be defined in the [alertmanager-main-secret](https://github.com/operate-first/apps/blob/master/cluster-scope/overlays/prod/common/alertmanager-main-secret.yaml#L64).
