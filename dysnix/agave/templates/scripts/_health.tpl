#!/usr/bin/env sh
# shellcheck disable=SC3040,SC2046

set -e

. /scripts/health.env

HTTP_PORT='{{ get .Values.agaveArgs "rpc-port" }}'

# expected output:
# - {"jsonrpc":"2.0","result":311384813,"id":1}
getMaxShredInsertSlot() {
    curl -s "http://$MY_POD_IP:$HTTP_PORT" \
        -H 'Content-Type: application/json' \
        -d '{"jsonrpc":"2.0","method":"getMaxShredInsertSlot","id":1}' | jq -r .result
}

# expected output:
# - {"jsonrpc":"2.0","result":311384813,"id":1}
getProcessedSlot() {
    curl -s "http://$MY_POD_IP:$HTTP_PORT" \
        -H 'Content-Type: application/json' \
        -d '{"jsonrpc":"2.0","method":"getSlot","params":[{"commitment": "processed"}],"id":1}' | jq -r .result
}

max_shred_insert_slot=$(($(getMaxShredInsertSlot)))
processed_slot=$(($(getProcessedSlot)))
slot_diff=$((max_shred_insert_slot - processed_slot))

if [ $slot_diff -ge $SLOT_DIFF_THRESHOLD ]; then
    echo "Node is $slot_diff slot(s) behind"
    exit 1
fi
