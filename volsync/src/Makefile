# This requires halberd [1] and yq [2].
#
# [1]: https://github.com/larsks/halberd
# [2]: https://kislyuk.github.io/yq/

all: manifests.yaml

manifests.yaml: kustomization.yaml
	kustomize build --enable-helm | \
		yq -y 'del(.metadata.creationTimestamp)' > $@ || { rm -f $@; exit 1; }

clean:
	rm -f manifests.yaml

install: install-cluster-scoped install-namespaced

install-cluster-scoped: manifests.yaml
	halberd -d ../../cluster-scope/base -vvkgN $<

install-namespaced: manifests.yaml
	mkdir -p ../base
	halberd -d ../base -vvgn $<
