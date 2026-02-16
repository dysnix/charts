#!/usr/bin/env bash
set -ex

usage() { echo "Usage: $0 <catchup_multiplier> <max_lag_in_seconds> <state_file>" 1>&2; exit 1; }

catchup_multiplier="$1"
max_lag_in_seconds="$2"
state_file="$3"

if [ -z "${catchup_multiplier}" ] || [ -z "${max_lag_in_seconds}" ] || [ -z "${state_file}" ]; then
    usage
fi

block_timestamp=$(geth --datadir={{ .Values.bsc.base_path }} attach --exec "eth.getBlock(eth.blockNumber).timestamp")

if [ -z "${block_timestamp}" ] || [ "${block_timestamp}" = "null" ]; then
    echo "Block timestamp returned by the node is empty or null"
    exit 1
fi

now=$(date +%s)
lag=$((now - block_timestamp))
mkdir -p $(dirname "${state_file}")

save_state() { echo "${block_timestamp} ${now}" > "${state_file}"; }

# Condition: block is within max_lag_in_seconds of current time
if [ ${lag} -le ${max_lag_in_seconds} ]; then
    echo "Node is synced: block lag ${lag}s <= ${max_lag_in_seconds}s"
    save_state
    exit 0
fi

# Condition: block time advancing catchup_multiplier times faster than wall clock
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
