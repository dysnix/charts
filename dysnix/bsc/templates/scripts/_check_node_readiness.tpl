#!/usr/bin/env sh
set -ex

public_bsc_node=$3
allowed_number_of_distinct_between_blocks=$2
allowed_number_of_time_gap_between_blocks=$2
local_node_endpoint=${4:-}

# Retrieving latest block timestamp from public bsc node
function get_public_block {
    geth --datadir=/tmp attach $public_bsc_node --exec "eth.blockNumber" || exit 0
}

# Retrieving latest local block number
function get_local_block {
    geth --config=/config/config.toml --datadir={{ .Values.bsc.base_path }} attach $local_node_endpoint --exec "eth.blockNumber"
}

# Retrieving latest block timestamp of a local bsc node
function get_local_timestamp {
   # TIMESTAMP_HEX=$(curl -s -X POST -H 'Content-Type: application/json' --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest", false],"id":1}' http://localhost:8575|jq -r .result.timestamp)
   # bash-only
   # print -v TIMESTAMP "%d" $TIMESTAMP_HEX
    geth --config=/config/config.toml --datadir={{ .Values.bsc.base_path }} attach $local_node_endpoint --exec "eth.getBlock(eth.blockNumber).timestamp"
}

case "$1" in
        # If public latest block number differs with local latest block for more than 10 blocks => fail, otherwise okay.
        --distinct-blocks)
            if [[ $(expr  $(get_public_block) - $(get_local_block)) -le $allowed_number_of_distinct_between_blocks ]]
            then
              echo "Current block gap is lower that $allowed_number_of_distinct_between_blocks"
              exit 0
            else
              echo "Current block gap is higher that $allowed_number_of_distinct_between_blocks."
              exit 1
            fi
            ;;
        # If local latest block's timestamp lower than current timestamp for more than 600 seconds (10 minutes)
        --timestamp-distinct)
            if [[ $(expr $(date +%s) - $(get_local_timestamp)) -le $allowed_number_of_time_gap_between_blocks ]]
            then
              echo  "Current timestamp gap is lower that $allowed_number_of_time_gap_between_blocks"
              exit 0
            else
              echo  "Current timestamp gap is higher that $allowed_number_of_time_gap_between_blocks"
              exit 1
            fi
            ;;
        *)
            echo "Usage: $0 {--distinct-blocks|--timestamp-distinct} {blocks-distinct,|time-range-distinct-seconds} {public-bsc-node-endpoint}
                  Blocks check:
                          $0 --distinct-blocks 10 https://bsc-dataseed1.binance.org
                  Timestamp check:
                          $0 --timestamp-distinct 300"
            exit 1
esac
