#!/usr/bin/env sh

# script performs BSC block prune from ancientDB, removing [unneeded in some cases] historical blocks
# good use case is a bootnode w/o RPC
# block prune should speed up node in runtime as well as allow to use less disk space
# after block prune the node will not be able to serve RPC on pruned blocks
# Around last 90000 blocks are kept in the node state before moving on to ancientDB

set -x

DATA_DIR="{{ .Values.bsc.base_path }}"

GETH=/usr/local/bin/geth
# how much recent blocks do we need to keep. Default 0 means we clean up ancientDB completely
BLOCKS_RESERVED=${1:-0}
{{- if eq .Values.bsc.state.scheme "path" }}
ANCIENT=${DATA_DIR}/geth/chaindata/ancient/chain/
{{- else }}
ANCIENT=${DATA_DIR}/geth/chaindata/ancient/
{{- end }}
ret=0
  # background logging
  tail -F "${DATA_DIR}/bsc.log" &
  # prune-block will turn our full node into light one actually
  $GETH --config=/config/config.toml --datadir=${DATA_DIR} --datadir.ancient=${ANCIENT} --cache {{ .Values.bsc.cache.value }} snapshot prune-block --block-amount-reserved=${BLOCKS_RESERVED}
  ret=$?
  if [ "${ret}" -eq "0" ];then
    # update timestamp
    date +%s > "${DATA_DIR}/block_prune_timestamp"
  fi

exit $ret
