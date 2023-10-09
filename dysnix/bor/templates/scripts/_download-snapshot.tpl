#!/bin/sh

set -e

if [ ! -f /data/.downloaded ]; then
  apt-get -y update && apt-get -y install wget
  wget -qO download.sh https://snapshot-download.polygon.technology/snapdown.sh
  sed -i 's/sudo//g' download.sh
  chmod +x download.sh

  ./download.sh --network {{ .Values.config.chain }} --client bor --extract-dir /data/bor/chaindata --validate-checksum true
  touch /data/.downloaded
else
  echo "Initial snapshot already downloaded, skipping."
fi
