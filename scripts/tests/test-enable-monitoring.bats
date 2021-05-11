#!/usr/bin/env bats

hash=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)

@test "fails if namespace does not exist" {
	run scripts/enable-monitoring.sh test-ns-$hash
	[[ $status -eq 1 ]]
}

@test "adds component to kustomization.yaml" {
	mkdir -p cluster-scope/base/core/namespaces/test-ns-$hash
	cat <<-EOF > cluster-scope/base/core/namespaces/test-ns-$hash/kustomization.yaml
	apiVersion: kustomize.config.k8s.io/v1beta1
	kind: Kustomization
	EOF

	scripts/enable-monitoring.sh test-ns-$hash
	grep -q monitoring-rbac cluster-scope/base/core/namespaces/test-ns-$hash/kustomization.yaml
}

teardown() {
	rm -rf cluster-scope/base/core/namespaces/test-ns-$hash
}
