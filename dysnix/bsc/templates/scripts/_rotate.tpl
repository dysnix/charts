#!/usr/bin/env bash

# this script rotates bootnodes - replaces old node with a new one
# scale up a new controller
# wait a couple hours for bootnode to grab some p2p peers
# ensure node is up & synced using JSON RPC via k8s service
# scale down an old controller

# We have to use 1 controller per bootnode due to external static IP and static node ID

# f.e statefulset/bootnode-0 or cloneset/bootnode-1
NEW_CONTROLLER="${1}"
#
OLD_CONTROLLER="${2}"
# bsc rpc endpoint to check, f.e. bsc-bootnode-0:8575, where bsc-bootnode-0 is a k8s service name pointing to a single node
RPC_ENDPOINT="${3}"
# node is allowed to lag for seconds
MAX_NODE_LAG=120
# wait for the new node to spin up and sync up
# ensure that cronjob's activeDeadlineSeconds is greater than this value
WAIT_TIME=7200

KUBECTL=$(which kubectl)
CURL=$(which curl)
JQ=$(which jq)

check_ret(){
        ret="${1}"
        msg="${2}"
        # allow to override exit code, default value is ret
        exit_code=${3:-${ret}}
        if [ ! "${ret}" -eq 0 ];then
                echo "${msg}"
                echo "return code ${ret}, exit code ${exit_code}"
                exit "${exit_code}"
        fi
}

# spinning up a new node
echo "$(date -Iseconds) scaling ${NEW_CONTROLLER} up to 1"
${KUBECTL} scale "${NEW_CONTROLLER}" --replicas=1
check_ret $? "$(date -Iseconds) FATAL: cannot scale ${NEW_CONTROLLER} to 1 replica" 1

# wait for a new node to sync up
echo "$(date -Iseconds) sleeping ${WAIT_TIME} seconds"
sleep ${WAIT_TIME}
echo "$(date -Iseconds) check node readinnes"

# health check
# cannot use existing check_node_readiness.sh as there is no bsc binary in this docker image
# get latest block and parse it's timestamp via jq
JSON_RPC_REQUEST='{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false],"id":1}'
LATEST_BLOCK_TIMESTAMP_HEX=$(${CURL} -s --data-binary ${JSON_RPC_REQUEST} -H 'Content-Type: application/json' "${RPC_ENDPOINT}"|${JQ} -r .result.timestamp)
[ -n "${LATEST_BLOCK_TIMESTAMP_HEX}" ]
check_ret $? "$(date -Iseconds) FATAL: node ${NEW_CONTROLLER} did not pass the health check - empty LATEST_BLOCK_TIMESTAMP_HEX" 2
echo "$(date -Iseconds) Latest block timestamp hex ${LATEST_BLOCK_TIMESTAMP_HEX}"

# convert timestamp from hex to dec
LATEST_BLOCK_TIMESTAMP=$(printf '%d' "${LATEST_BLOCK_TIMESTAMP_HEX}")
[ -n "${LATEST_BLOCK_TIMESTAMP}" ]
check_ret $? "$(date -Iseconds) FATAL: node ${NEW_CONTROLLER} did not pass the health check - empty LATEST_BLOCK_TIMESTAMP" 3
echo "$(date -Iseconds) Latest block timestamp ${LATEST_BLOCK_TIMESTAMP}"

# is node synced up ?
[[ $(($(date +%s) - ${LATEST_BLOCK_TIMESTAMP})) -le ${MAX_NODE_LAG} ]]
check_ret $? "$(date -Iseconds) FATAL: node ${NEW_CONTROLLER} timestamp lag is greater than ${MAX_NODE_LAG}, ts=${LATEST_BLOCK_TIMESTAMP}, now=$(date +%s)" 4
echo "$(date -Iseconds) node ${NEW_CONTROLLER} timestamp ${LATEST_BLOCK_TIMESTAMP} is fresh, now=$(date +%s)"

# scaling down an old node
echo "$(date -Iseconds) scaling ${OLD_CONTROLLER} down to 0"
${KUBECTL} scale "${OLD_CONTROLLER}" --replicas=0
check_ret $? "$(date -Iseconds) FATAL: cannot scale ${OLD_CONTROLLER} to 0 replica" 5
exit 0
