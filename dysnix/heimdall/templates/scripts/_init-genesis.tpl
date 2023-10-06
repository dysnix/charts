#!/bin/sh

set -e

if [ ! -f /data/.initialized ]; then
  /usr/bin/heimdalld init --home /data
  wget -O /data/config/genesis.json {{ .Values.init.genesisUrl }}
  touch /data/.initialized
else
  echo "Heimdall is already initialized, skipping init."
fi
