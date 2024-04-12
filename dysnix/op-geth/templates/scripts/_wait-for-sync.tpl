#!/usr/bin/env sh
# shellcheck disable=SC3040

# We assume that node is syncing from initial snapshot when:
# (get_block_number == 0x0) OR (is_syncing == true)

set -ex

HTTP_PORT="{{ .Values.config.http.port }}"

# expected output format: 0x50938d
get_block_number() {
    wget "http://localhost:$HTTP_PORT" -qO- \
        --header 'Content-Type: application/json' \
        --post-data '{"jsonrpc":"2.0","method":"eth_blockNumber","id":1}' \
    | sed -r 's/.*"result":"([^"]+)".*/\1/g'
}

# exit codes: 1 = sync completed, 0 = sync in progress
is_syncing() {
    wget "http://localhost:$HTTP_PORT" -qO- \
        --header 'Content-Type: application/json' \
        --post-data '{"jsonrpc":"2.0","method":"eth_syncing","id":1}' \
    | grep -qv "false"
}

if ! get_block_number | grep -qE '^0x[a-z0-9]+'; then
    echo "Error reading block number"; exit 1
fi

if is_syncing || [ "$(get_block_number)" = "0x0" ]; then
    echo "Initial sync is in progress"
    exit 1
else
    exit 0
fi