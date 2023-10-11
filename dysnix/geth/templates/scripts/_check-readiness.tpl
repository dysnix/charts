#!/usr/bin/env sh
set -e

# Retrieving latest block timestamp
get_block_timestamp() {
  geth --{{ .Values.config.eth.network }} attach --exec "eth.getBlock(eth.blockNumber).timestamp" 2>/dev/null
}

if [ -z $1 ]; then
  echo "Usage: $0 {allowed-block-gap-in-seconds}" && exit 1
fi

allowed_gap=$1
current_gap=$(($(date +%s) - $(get_block_timestamp)))

if [ $current_gap -le $allowed_gap ]; then
  exit 0
else
  echo "Current block timestamp gap ($current_gap) is higher than allowed ($allowed_gap)" && exit 1
fi