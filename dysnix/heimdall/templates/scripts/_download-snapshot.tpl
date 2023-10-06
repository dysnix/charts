#!/bin/sh

set -e

if [ ! -f /data/.downloaded ]; then
  apt-get -y update && apt-get -y install wget
  wget -qO download.sh https://snapshot-download.polygon.technology/snapdown.sh
  sed -i 's/sudo//g' download.sh
  chmod +x download.sh

  ./download.sh --network {{ .Values.network }} --client heimdall --extract-dir /data/data --validate-checksum false
  touch /data/.downloaded
else
  echo "Initial snapshot already downloaded, skipping."
fi
