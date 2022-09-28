#!/usr/bin/env bash

set -e
set -x

# install mustache from https://github.com/cbroglie/mustache

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
RESOURCE=$1

cd $SCRIPT_DIR/..
mustache $SCRIPT_DIR/patches/${RESOURCE}.yaml $SCRIPT_DIR/patches/${RESOURCE}.diff.mustache | git apply --check -v

