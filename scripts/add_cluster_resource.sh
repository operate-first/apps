#!/bin/sh

set -o errexit
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o errtrace
set -o pipefail

_BN="$(basename "${0}")"

_usage() {
cat <<HEREDOC

Fetch a cluster resource from github and add it to cluster-scope app.

Usage:
  ${_BN} [env] [cluster] [flags]

Mandatory flags (mutually exclusive):
  -f, --file    path to file on local filesystem
  -u, --url     remote git url for the raw file

Optional Flags:
  -h, --help    help for this script

Example:
  ${_BN} moc zero -f /tmp/manifest.yaml
  ${_BN} moc zero -u https://raw.githubusercontent.com/<github_user>/<repo>/master/<path-to-manifest>/manifest.yaml

HEREDOC
}

# Keep values sorted alphabetically since `kustomize edit resource add` just appends.
_sort_kustomize_values(){
  tmpfile=$(mktemp)
  yq e -j kustomization.yaml | jq 'map_values(select(. >= []) |= sort)' | yq e -P > ${tmpfile}
  mv ${tmpfile} ./kustomization.yaml
  kustomize edit fix
}

_get_plural(){
  kind=${1}
  apiVersion=${2}
  cat ./scripts/api-resources.txt  | grep "\b${kind}\b" | grep ${apiVersion} | awk '{print $1}'
}

_add_resource(){
  env=${1}
  cluster=${2}
  src=${3}
  kind=`yq e '.kind' ${src}`
  apiVersion=`yq e '.apiVersion' ${src}`
  resource_dir=`_get_plural ${kind} ${apiVersion}`
  filename=$(echo "$kind" | awk '{print tolower($0)}').yaml
  resource_name=`yq e '.metadata.name' ${src}`
  base_dest="cluster-scope/base/${resource_dir}/${resource_name}"
  overlay_dest="cluster-scope/overlays/${env}/${cluster}"

  mkdir -p ${base_dest}
  pushd ${base_dest} > /dev/null
  kustomize init
  cp ${src} ./${filename}
  kustomize edit add resource ./${filename}

  echo "Resource ${kind}/${resource_name} added to ${base_dest}"

  popd > /dev/null
  pushd ${overlay_dest} > /dev/null
  kustomize edit add resource ../../../base/${resource_dir}/${resource_name}
  _sort_kustomize_values
  popd > /dev/null

  echo "Updated kustomization.yaml at ${overlay_dest}"
}

_remote_manifest(){
  echo "Fetching remote manifest..."
  env=${1}
  cluster=${2}
  url=${3}
  http_code=$(curl -s -o /dev/null -w "%{http_code}" ${url})
  if [ ${http_code} -ne "200" ]; then
    echo "Resource was not found at ${url}, exiting."
    exit 1
  fi
  src="/tmp/fetch_cluster_resource.$(uuidgen)"
  wget -q ${url} -O ${src}

  echo "Adding remote manifest to cluster-scope app..."
  _add_resource ${env} ${cluster} ${src}
  rm ${src}
  echo "Adding remote manifest completed."
}

_local_manifest(){
  echo "Adding local manifest to cluster-scope app..."
  env=${1}
  cluster=${2}
  src=${3}
  _add_resource ${env} ${cluster} ${src}
  echo "Adding local manifest completed."
}

main() {
  # Ensure we're in the relative root of the cloned repository
  if [ ! -d "cluster-scope" ]; then
    echo "The cluster-scope directory was not found. Please execute this script from the root of the operate-first/app cloned repository."
  fi

  # Simple arg validation
  if [ $# -ne 4 ] || [ "$#" == "--help" ] || [ "$#" == "-h" ]; then
    _usage
    exit 0
  fi

  env=${1}
  cluster=${2}
  location=${4}

  # Simple flag parse
  if [ "$3" == "--file" ] || [ "$3" == "-f" ]; then
    _local_manifest ${env} ${cluster} ${location}
  elif [ "$3" == "--url" ] || [ "$3" == "-u" ]; then
    _remote_manifest ${env} ${cluster} ${location}
  else
    echo "Invalid options or flags specified."
    _usage
    exit 1
  fi

}

main $@
