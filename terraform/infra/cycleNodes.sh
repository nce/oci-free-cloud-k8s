#!/bin/bash
set -e

singleNodeToDelete="na"

function print_usage() {
    echo "$*"
    echo "Usage: $0 <node-ip-address> (optional)"
    echo ""
    echo "This script will sequentially delete each node in the node-pool, scaling up before each deletion."
    echo "It waits for Longhorn to report all volumes as healthy after each deletion."
    echo ""
    echo "Environment variables:"
    echo "  OCI_CLI_PROFILE - (optional) OCI CLI profile to use. If not set, default profile is used."
    echo "  KUBECONFIG      - (optional) Path to kubeconfig file. If not set, default kubeconfig is used."
    echo ""

    if [ -z "$OCI_CLI_PROFILE" ]; then
        echo "OCI_CLI_PROFILE not set. Running with default profile."
    else
        echo "Using OCI_CLI_PROFILE: ${OCI_CLI_PROFILE}"
    fi

    if [ -z "$KUBECONFIG" ]; then
        echo "KUBECONFIG not set. Running with default."
    else
        echo "Using KUBECONFIG: ${KUBECONFIG}"
    fi

    if [ -z "$1" ]; then
      echo "Cycling all nodes in the node-pool."
    else
      singleNodeToDelete="$1"
      echo "Replacing Node with IP: ${singleNodeToDelete}"
    fi
}

function confirm_proceed() {
    msg="This operation will upgrade all nodes in the node-pool one by one. Do you want to proceed? (y/n): "
    if [ "${singleNodeToDelete}" != "na" ]; then
        msg="This operation will upgrade the node with IP ${singleNodeToDelete}. Do you want to proceed? (y/n): "
    fi
    read -p "$msg" choice
    case "$choice" in
      y|Y ) echo "Proceeding with node upgrade...";;
      n|N ) echo "Operation cancelled."; exit 0;;
      * ) echo "Invalid choice. Please enter y or n."; confirm_proceed;;
    esac
}

function check_dependencies() {
    command -v oci >/dev/null 2>&1 || { echo >&2 "OCI CLI is required but it's not installed. Aborting."; exit 1; }
    command -v terraform >/dev/null 2>&1 || { echo >&2 "Terraform is required but it's not installed. Aborting."; exit 1; }
    command -v jq >/dev/null 2>&1 || { echo >&2 "jq is required but it's not installed. Aborting."; exit 1; }
    command -v kubectl >/dev/null 2>&1 || { echo >&2 "kubectl is required but it's not installed. Aborting."; exit 1; }
    echo "All checks passed."
}

function ensure_longhorn_namespace() {
    if ! kubectl get namespace longhorn >/dev/null 2>&1; then
        echo "Longhorn namespace 'longhorn' does not exist. Please install Longhorn before running this script."
        exit 1
    fi
}

function upgradeNodes() {
  waitForState="--wait-for-state SUCCEEDED --wait-for-state FAILED --force"
  nodesFilter="[.data.nodes[] | select( .\"lifecycle-state\" == \"ACTIVE\")][].id"
  compartmentId=$(terraform output --raw compartment_id)
  nodePoolId=$(oci ce node-pool list --compartment-id "${compartmentId}" | jq -r ".data[].id")
  echo "Node-pool id: ${nodePoolId}"

  if [ "${singleNodeToDelete}" != "na" ]; then
    nodesFilter="[.data.nodes[] | select( .\"lifecycle-state\" == \"ACTIVE\" and .\"private-ip\" == \"${singleNodeToDelete}\")][].id"
  fi

  oldNodes=$(oci ce node-pool get --node-pool-id ${nodePoolId} | jq -r "${nodesFilter}")
  echo "Nodes to be replaced:"
  echo "${oldNodes}"
  sleep 10

  echo "${oldNodes}" | while IFS= read -r nodeToBeDeleted
  do
    echo "Scale node-pool up to 3 (${nodePoolId})"
    oci ce node-pool update --size 3 --node-pool-id ${nodePoolId} ${waitForState}

    echo "Deleting node ${nodeToBeDeleted}"
    oci ce node-pool delete-node --node-pool-id ${nodePoolId} --node-id ${nodeToBeDeleted} ${waitForState}

    echo "Waiting for longhorn to sync volumes on new node"
    longhornNotHealthy=1

    while [ ${longhornNotHealthy} -gt 0 ]
    do
      longhornNotHealthy=$(kubectl get volume -n longhorn -o=jsonpath="{range .items[*]}{.status.robustness} {.status.state}{\"\n\"}" | grep attached | awk {'print $1'} | grep -v healthy | wc -l)
      echo "${longhornNotHealthy} not healthy volumes"
      sleep 10
    done

    echo "All volumes healthy now"
  done
}

print_usage "$@"
check_dependencies
ensure_longhorn_namespace
confirm_proceed
upgradeNodes
