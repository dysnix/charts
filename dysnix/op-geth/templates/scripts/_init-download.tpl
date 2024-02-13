#!/usr/bin/env sh
set -e

# TODO: improve zstd extraction with mbuffer

mkdir -p /root/.ethereum/{{ .Values.config.network }}
cd /root/.ethereum/{{ .Values.config.network }}

if [ ! -f /root/.ethereum/.downloaded ]; then
  echo "Not initialized, proceeding with download..."
  {{- if contains "lz4" .Values.init.download.url }}
  apk add lz4
  wget -qO- {{ .Values.init.download.url }} | lz4 -cd | tar -xvf -
  {{- else if contains "zstd" .Values.init.download.url }}
  apk add zstd
  wget -qO- {{ .Values.init.download.url }} | zstd -cd | tar -xvf -
  {{- else }}
  wget -qO- {{ .Values.init.download.url }} | tar -xvf -
  {{- end }}
  touch /root/.ethereum/.downloaded
else
  echo "Already initialized, skipping."
fi