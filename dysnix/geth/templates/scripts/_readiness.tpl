#!/usr/bin/env sh
# shellcheck disable=SC3040

# Node is ready when the latest block is fresh enough.
# We are checking the timestamp of the latest block and compare it to current local time.

set -eo pipefail

HTTP_PORT="8545"
AGE_THRESHOLD=$1

if [ -z "$AGE_THRESHOLD" ]; then
    echo "Usage: $0 <block age threshold>"; exit 1
fi

get_block_timestamp() {
    wget "http://localhost:$HTTP_PORT" -qO- \
        --header 'Content-Type: application/json' \
        --post-data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest", false],"id":1}' \
    | grep -oE '"timestamp":".*"' | cut -d',' -f1 | cut -d':' -f2 | tr -d '"'
}

age=$(($(date +%s) - $(get_block_timestamp)))

if [ $age -le $AGE_THRESHOLD ]; then
    exit 0
else
    echo "Latest block is $age seconds old. Threshold is $AGE_THRESHOLD seconds" && exit 1
fi