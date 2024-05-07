#!/usr/bin/env sh
# shellcheck disable=SC3040,SC2046

set -e

HTTP_PORT='{{ get .Values.solanaArgs "rpc-port" }}'

# expected outputs:
# - {"jsonrpc":"2.0","result":"ok","id":1}
# - {"jsonrpc":"2.0","error":{"code":-32005,"message":"Node is unhealthy","data":{}},"id":1}
get_health() {
    curl -s "http://$MY_POD_IP:$HTTP_PORT" \
        -H 'Content-Type: application/json' \
        -d '{"jsonrpc":"2.0","method":"getHealth","id":1}'
}

if get_health | jq -r --exit-status '.error.message'; then
    exit 1
fi

exit 0