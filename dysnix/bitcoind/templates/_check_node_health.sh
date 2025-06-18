#!/usr/bin/env bash
set -ex # -e exits on error

usage() { echo "Usage: $0 <datadir> <max_lag_in_seconds> <last_synced_block_file>]" 1>&2; exit 1; }

datadir="$1"
max_lag_in_seconds="$2"
last_synced_block_file="$3"

if [ -z "${datadir}" ] || [ -z "${max_lag_in_seconds}" ] || [ -z "${last_synced_block_file}" ]; then
    usage
fi

set +e

# it may take up to 5-10 minutes during sync
block_number=$({{ .Values.bitcoind.cli_binary }}  -datadir=${datadir} getblockcount)

ret=$?
# https://en.bitcoin.it/wiki/Original_Bitcoin_client/API_calls_list#Error_Codes
if [[ "$ret" -eq "28" ]];then
  echo Loading block index...
  exit 0
fi

set -e

number_re='^[0-9]+$'
if [ -z "${block_number}" ] || [[ ! ${block_number} =~ $number_re ]]; then
    echo "Block number returned by the node is empty or not a number"
    exit 1
fi

# handling special case with blockchain re-index
if [[ "$block_number" -eq "0" ]];then
  echo "Reindexing ..."
  exit 0
fi

if [ ! -f ${last_synced_block_file} ]; then
    old_block_number="";
else
    old_block_number=$(cat ${last_synced_block_file});
fi;

if [ "${block_number}" != "${old_block_number}" ]; then
  mkdir -p $(dirname "${last_synced_block_file}")
  echo ${block_number} > ${last_synced_block_file}
fi

file_age=$(($(date +%s) - $(date -r ${last_synced_block_file} +%s)));
max_age=${max_lag_in_seconds};
echo "${last_synced_block_file} age is $file_age seconds. Max healthy age is $max_age seconds";
if [ ${file_age} -lt ${max_age} ]; then exit 0; else exit 1; fi
