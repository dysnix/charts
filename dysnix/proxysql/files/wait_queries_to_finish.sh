#!/usr/bin/env bash

echo "Waiting for proxy queries to finish..."

while true; do
  CONNECTED_IPS=$(for pid in $(pidof proxysql); do cat /proc/${pid}/net/tcp \
    | awk '{print $3}' \
    | grep -i $(printf ":%x" "${PROXYSQL_SERVICE_PORT_PROXY:-6033}") \
    | sort -u \
    | cut -f1 -d':' \
    | awk '{gsub(/../,"0x& ")} OFS="." {for(i=NF;i>0;i--) printf "%d%s", $i, (i == 1 ? ORS : OFS)}'; \
    done )

  if [[ -z ${CONNECTED_IPS} ]]; then
    echo "Done. Exiting...";
    exit 0
  else
    echo "Connected IPs: $(echo ${CONNECTED_IPS} | wc -l). Sleeping... ${CONNECTED_IPS}";
    sleep $[ ( $RANDOM % 3 )  + 1 ]s
  fi;
done
