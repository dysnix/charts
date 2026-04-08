#!/usr/bin/env bash
set -e

# Node is alive when either:
# 1. Latest block is within max_lag_in_seconds of current time (synced), or
# 2. Block time is advancing at least catchup_multiplier times faster than wall clock (catching up)

usage() { echo "Usage: $0 <catchup_multiplier> <max_lag_in_seconds> <state_file>" 1>&2; exit 1; }

catchup_multiplier="$1"
max_lag_in_seconds="$2"
state_file="$3"
HTTP_PORT="{{ .Values.config.http.port }}"

if [ -z "${catchup_multiplier}" ] || [ -z "${max_lag_in_seconds}" ] || [ -z "${state_file}" ]; then
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

get_block_timestamp() {
    rpc_call '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest", false],"id":1}' \
    | sed -r 's/.*"timestamp":"([^"]+)".*/\1/g'
}

block_timestamp=$(($(get_block_timestamp)))

if [ -z "${block_timestamp}" ] || ! echo "${block_timestamp}" | grep -qE '^[0-9]+$'; then
    echo "Block timestamp returned by the node is empty or invalid"
    exit 1
fi

now=$(date +%s)
lag=$((now - block_timestamp))
mkdir -p "$(dirname "${state_file}")"

save_state() { echo "${block_timestamp} ${now}" > "${state_file}"; }

# Condition 1: block is within max_lag_in_seconds of current time
if [ ${lag} -le ${max_lag_in_seconds} ]; then
    echo "Node is synced: block lag ${lag}s <= ${max_lag_in_seconds}s"
    save_state
    exit 0
fi

# Condition 2: block time advancing catchup_multiplier times faster than wall clock
if [ -f "${state_file}" ]; then
    read -r prev_block_timestamp prev_wall_time < "${state_file}"

    wall_delta=$((now - prev_wall_time))
    block_delta=$((block_timestamp - prev_block_timestamp))

    if [ ${wall_delta} -gt 0 ]; then
        threshold=$((catchup_multiplier * wall_delta))
        if [ ${block_delta} -ge ${threshold} ]; then
            echo "Node is catching up: block time advanced ${block_delta}s in ${wall_delta}s (>= ${catchup_multiplier}x)"
            save_state
            exit 0
        fi
    fi
fi

# Save state for next check
save_state

echo "Node is unhealthy: block lag ${lag}s > ${max_lag_in_seconds}s and not catching up fast enough"
exit 1