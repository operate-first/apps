#!/bin/bash

set -o errexit
set -o nounset

: ${LABEL_LOOP_INTERVAL:=300}

if [[ -z $NODE_NAME ]]; then
    echo "ERROR: cannot continue without local node name" >&2
    exit 1
fi

while :; do
    primary=$(ip route | awk '$1 == "default" {print $5}' | head -1)
    if [[ -z $primary ]]; then
        echo "ERROR: failed to find primary interface for $NODE_NAME" >&2
        continue
    fi
    echo "Found primary interface $primary on node $NODE_NAME"
    oc label --overwrite node/$NODE_NAME massopen.cloud/primary-interface=$primary
    sleep $LABEL_LOOP_INTERVAL
done
