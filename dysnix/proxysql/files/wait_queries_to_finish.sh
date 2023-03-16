#!/usr/bin/env bash

# For all proxysql processes iterate over all tcp connection
# and search for established connection to port ${PROXYSQL_SERVICE_PORT_PROXY:-6033}.
# If more than one connection if found, randomly slepp up to 3 seconds,
# otherwise exit 0.

set -u

echo "Waiting for proxy queries to finish..."

while true; do
  CONNECTED_IPS=$(for pid in $(pidof proxysql); do \
    cat /proc/${pid}/net/tcp \
    | grep -E "[[:digit:]]+: [[:xdigit:]]+$(printf ':%x' ${PROXYSQL_SERVICE_PORT_PROXY:-6033}) [[:xdigit:]]+:[[:xdigit:]]+ 01" \
    | sort -u \
    | cut -f1 -d':' \
    | awk '{gsub(/../,"0x& ")} OFS="." {for(i=NF;i>0;i--) printf "%d%s", $i, (i == 1 ? ORS : OFS)}'; \
    done )

  echo "Connected IPs: $(echo ${CONNECTED_IPS} | wc -l)"
  if [[ -z ${CONNECTED_IPS} ]]; then
    echo "Done. Exiting...";
    exit 0
  else
    echo "Sleeping...";
    sleep $[ ( $RANDOM % 3 )  + 1 ]s
  fi;
done
