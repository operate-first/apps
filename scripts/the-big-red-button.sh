#!/bin/bash

# Function to scale down a workload to zero replicas
scale_down_workload() {
  local namespace="$1"
  local workload_type="$2"
  local workload_name="$3"

  echo "Scaling down $workload_type $workload_name in namespace $namespace to 0 replicas..."
  oc scale $workload_type $workload_name --replicas=0 -n $namespace
}

# Check if 'oc' command is available
if ! command -v oc &> /dev/null; then
  echo "Error: 'oc' command not found. Please make sure you have OpenShift CLI installed and in your PATH."
  exit 1
fi

# Check if namespaces are provided as input
if [ $# -eq 0 ]; then
  echo "Error: Please provide a list of namespaces as input."
  exit 1
fi

# Loop through each namespace provided as input
for namespace in "$@"; do
  # Get all deployments in the namespace
  deployments=$(oc get deployments -n $namespace -o custom-columns=":metadata.name" --no-headers)

  # Scale down deployments to zero replicas
  for deployment in $deployments; do
    scale_down_workload $namespace "deployment" $deployment
  done

  # Get all replicasets in the namespace
  replicasets=$(oc get replicasets -n $namespace -o custom-columns=":metadata.name" --no-headers)

  # Scale down replicasets to zero replicas
  for replicaset in $replicasets; do
    scale_down_workload $namespace "replicaset" $replicaset
  done

  # Get all statefulsets in the namespace
  statefulsets=$(oc get statefulsets -n $namespace -o custom-columns=":metadata.name" --no-headers)

  # Scale down statefulsets to zero replicas
  for statefulset in $statefulsets; do
    scale_down_workload $namespace "statefulset" $statefulset
  done

  # Get routes
  routes=$(oc get routes -n $namespace -o custom-columns=":metadata.name" --no-headers)

  # Delete routes
  for route in $routes; do
    oc delete route $route -n $namespace 
  done


  echo "All workloads in namespace $namespace scaled down to 0 replicas, and routes have been deleted."
done

echo "Done!"
