#!/usr/bin/env bash
set -e

# Node startup probe: tracks block number advancement.
# Passes when a new block is imported within max_lag_in_seconds.

usage() { echo "Usage: $0 <max_lag_in_seconds> <last_synced_block_file>" 1>&2; exit 1; }

max_lag_in_seconds="$1"
last_synced_block_file="$2"
HTTP_PORT="{{ .Values.config.http.port }}"

if [ -z "${max_lag_in_seconds}" ] || [ -z "${last_synced_block_file}" ]; then
    usage
fi

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

get_block_number() {
    rpc_call '{"jsonrpc":"2.0","method":"eth_blockNumber","id":1}' \
    | sed -r 's/.*"result":"([^"]+)".*/\1/g'
}

block_number=$(get_block_number)

if [ -z "${block_number}" ] || [ "${block_number}" = "null" ]; then
    echo "Block number returned by the node is empty or null"
    exit 1
fi

if [ ! -f "${last_synced_block_file}" ]; then
    old_block_number=""
else
    old_block_number=$(cat "${last_synced_block_file}")
fi

if [ "${block_number}" != "${old_block_number}" ]; then
    mkdir -p "$(dirname "${last_synced_block_file}")"
    echo "${block_number}" > "${last_synced_block_file}"
fi

file_age=$(($(date +%s) - $(date -r "${last_synced_block_file}" +%s)))
echo "${last_synced_block_file} age is ${file_age} seconds. Max healthy age is ${max_lag_in_seconds} seconds"
if [ ${file_age} -lt ${max_lag_in_seconds} ]; then exit 0; else exit 1; fi