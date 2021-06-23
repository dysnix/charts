set -ex # -e exits on error

usage() { echo "Usage: $0 <rpc_endpoint> <max_lag_in_seconds> <last_synced_block_file>]" 1>&2; exit 1; }

rpc_endpoint="$1"
max_lag_in_seconds="$2"
last_synced_block_file="$3"

if [ -z "${rpc_endpoint}" ] || [ -z "${max_lag_in_seconds}" ] || [ -z "${last_synced_block_file}" ]; then
    usage
fi

block_number=$(geth --datadir={{ .Values.bsc.base_path }} attach --exec "eth.blockNumber")

if [ -z "${block_number}" ] || [ "${block_number}" == "null" ]; then
    echo "Block number returned by the node is empty or null"
    exit 1
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
