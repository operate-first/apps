#!/usr/bin/env bats

hash=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)

@test "creates a project" {
	scripts/onboarding.sh test-ns-$hash test-owner-$hash
	[[ -d cluster-scope/base/core/namespaces/test-ns-$hash ]]
	[[ -d cluster-scope/base/user.openshift.io/groups/test-owner-$hash ]]
	[[ -d cluster-scope/components/project-admin-rolebindings/test-owner-$hash ]]
}

@test "fails if namespace exists" {
	mkdir cluster-scope/base/core/namespaces/test-ns-$hash
	run scripts/onboarding.sh test-ns-$hash test-owner-$hash
	[[ $status -eq 1 ]]
}

@test "does not create group if dir exists" {
	mkdir cluster-scope/base/user.openshift.io/groups/test-owner-$hash
	echo "name: test-owner-$hash" > cluster-scope/base/user.openshift.io/groups/test-owner-$hash/fake-group.yaml
	run scripts/onboarding.sh test-ns-$hash test-owner-$hash
	! [[ -f cluster-scope/base/user.openshift.io/groups/test-owner-$hash/group.yaml ]]
}

teardown() {
	rm -rf cluster-scope/base/core/namespaces/test-ns-$hash
        rm -rf cluster-scope/base/user.openshift.io/groups/test-owner-$hash
        rm -rf cluster-scope/components/project-admin-rolebindings/test-owner-$hash
}
