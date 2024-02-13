#!/usr/bin/env sh
set -e

if [ ! -f /root/.ethereum/.initialized ]; then
    wget -qO /tmp/genesis.json "{{ .Values.init.genesis.url }}"
    geth init /tmp/genesis.json
    touch /root/.ethereum/.initialized
    echo "Successfully initialized from genesis file"
else
    echo "Already initialized, skipping."
fi