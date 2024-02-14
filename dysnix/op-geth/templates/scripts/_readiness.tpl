#!/usr/bin/env sh
# shellcheck disable=SC3040

# Node is ready when the latest block is fresh enough.
# We are checking the timestamp of the latest block and compare it to current local time.

set -e

HTTP_PORT="{{ .Values.config.http.port }}"
AGE_THRESHOLD=$1

if [ -z "$AGE_THRESHOLD" ]; then
    echo "Usage: $0 <block age threshold>"; exit 1
fi

# expected output format: 0x65cb8ca8
get_block_timestamp() {
    wget "http://localhost:$HTTP_PORT" -qO- \
        --header 'Content-Type: application/json' \
        --post-data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest", false],"id":1}' \
    | sed -r 's/.*"timestamp":"([^"]+)".*/\1/g'
}

# using $(()) converts hex string to number
block_timestamp=$(($(get_block_timestamp)))
current_timestamp=$(date +%s)

if ! echo "$block_timestamp" | grep -qE '^[0-9]+$'; then
    echo "Error reading block timestamp"; exit 1
fi

age=$((current_timestamp - block_timestamp))

if [ $age -le $AGE_THRESHOLD ]; then
    exit 0
else
    echo "Latest block is $age seconds old. Threshold is $AGE_THRESHOLD seconds" && exit 1
fi