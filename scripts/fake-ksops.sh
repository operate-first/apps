#!/bin/sh
#
# Set up a fake ksops plugin

tmpdir=$(mktemp -d $PWD/pluginsXXXXXX)
trap "rm -rf $tmpdir" EXIT

mkdir -p $tmpdir/viaduct.ai/v1/ksops
ln -s /bin/true $tmpdir/viaduct.ai/v1/ksops/ksops
export KUSTOMIZE_PLUGIN_HOME=$tmpdir

"$@"
