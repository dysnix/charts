#!/usr/bin/env sh
# shellcheck disable=SC3040

# Node is alive when new blocks are being imported.
# We are checking the age when last block import event occured.

set -eo pipefail

AGE_THRESHOLD=$1
STATE_FILE=${2:-"/root/.ethereum/saved_block_number.txt"}
HTTP_PORT="{{ .Values.config.node.http.port }}"

if [ -z "${AGE_THRESHOLD}" ] || [ -z "${STATE_FILE}" ]; then
    echo "Usage: $0 <last block import age threshold> [state file]" 1>&2; exit 1
fi


# expected output format: 0x50938d
get_block_number() {
    wget "http://localhost:$HTTP_PORT" -qO- \
        --header 'Content-Type: application/json' \
        --post-data '{"jsonrpc":"2.0","method":"eth_blockNumber","id":1}' \
    | sed -r 's/.*"result":"([^"]+)".*/\1/g'
}

# using $(()) converts hex string to number
block_number=$(($(get_block_number)))
saved_block_number=""

if ! echo "$block_number" | grep -qE '^[0-9]+$'; then
    echo "Error reading block number"; exit 1
fi

if [ -f "${STATE_FILE}" ]; then
    saved_block_number=$(cat "${STATE_FILE}")
fi

if [ "${block_number}" != "${saved_block_number}" ]; then
  mkdir -p "$(dirname "${STATE_FILE}")"
  echo "${block_number}" > "${STATE_FILE}"
fi

current_timestamp=$(date +%s)
last_import_timestamp=$(date -r "${STATE_FILE}" +%s)

age=$((current_timestamp - last_import_timestamp))

if [ $age -lt $AGE_THRESHOLD ]; then
    exit 0
else
    echo "Last block import event was $age seconds ago. Threshold is $AGE_THRESHOLD seconds"; exit 1
fi