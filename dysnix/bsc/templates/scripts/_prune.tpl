#!/usr/bin/env sh

set -x
# env required
# BSC_PRUNE = True or any other value

DATA_DIR="{{ .Values.bsc.base_path }}"

# TODO
# mark cloud timestamp as outdated, as we're not going to provide a fresh snapshot soon
# it should be done by operator - just keep pod up & running for some time and cloud timestamp will lag on it's own

GETH=/usr/local/bin/geth

ret=0
# we need to check env var to start pruning
if [ "${BSC_PRUNE}" == "True" ] ; then
  # background logging
  tail -F "${DATA_DIR}/bsc.log" &
  $GETH --config=/config/config.toml --datadir=${DATA_DIR} --cache {{ .Values.bsc.cache.value }} snapshot prune-state
  # prune-block will turn our full node into light one actually
  # $GETH --config=/config/config.toml --datadir=${DATA_DIR} --datadir.ancient=${DATA_DIR}/geth/chaindata/ancient --cache {{ .Values.bsc.cache.value }} snapshot prune-block
  ret=$?
  if [ "${ret}" -eq "0" ];then
    # update timestamp
    date +%s > "${DATA_DIR}/prune_timestamp"
  fi
fi

exit $ret
