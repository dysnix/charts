#!/bin/sh

set -e

if [ ! -f /data/.initialized ]; then
  wget -O /data/genesis.json {{ .Values.init.genesis.downloadUrl }}
  touch /data/.initialized
else
  echo "Genesis is already downloaded, skipping."
fi
