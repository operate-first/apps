FROM quay.io/operate-first/opf-toolbox:v0.4.2 AS toolbox
FROM quay.io/thoth-station/s2i-custom-py38-notebook:v0.4.1

ENV XDG_CONFIG_HOME=/usr/share/.config

ENV KUSTOMIZE_PLUGIN_PATH=$XDG_CONFIG_HOME/kustomize/plugin/

COPY --from=toolbox /usr/local/bin /usr/local/bin
COPY --from=toolbox $KUSTOMIZE_PLUGIN_PATH/viaduct.ai/v1/ksops $KUSTOMIZE_PLUGIN_PATH/viaduct.ai/v1/ksops
