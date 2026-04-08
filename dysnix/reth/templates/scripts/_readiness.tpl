#!/usr/bin/env bash
set -e

# Node is ready when the latest block timestamp is within the allowed gap.

usage() { echo "Usage: $0 --timestamp-distinct <max_seconds>" 1>&2; exit 1; }

HTTP_PORT="{{ .Values.config.http.port }}"

# JSON-RPC call via bash /dev/tcp (no wget/curl dependency)
rpc_call() {
    local body="$1"
    local len=${#body}
    {
        printf "POST / HTTP/1.1\r\nHost: localhost\r\nContent-Type: application/json\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s" "$len" "$body"
    } | {
        exec 3<>/dev/tcp/localhost/$HTTP_PORT
        cat >&3
        cat <&3
        exec 3>&-
    } | sed -n '/^\r$/,$p' | tail -n +2
}

get_block_timestamp() {
    rpc_call '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest", false],"id":1}' \
    | sed -r 's/.*"timestamp":"([^"]+)".*/\1/g'
}

case "$1" in
    --timestamp-distinct)
        max_gap=$2
        if [ -z "${max_gap}" ]; then usage; fi

        block_timestamp=$(($(get_block_timestamp)))
        if ! echo "$block_timestamp" | grep -qE '^[0-9]+$'; then
            echo "Error reading block timestamp"; exit 1
        fi

        gap=$(($(date +%s) - block_timestamp))

        if [ ${gap} -le ${max_gap} ]; then
            echo "Current timestamp gap is ${gap}s <= ${max_gap}s"
            exit 0
        else
            echo "Current timestamp gap is ${gap}s > ${max_gap}s"
            exit 1
        fi
        ;;
    *)
        usage
        ;;
esac