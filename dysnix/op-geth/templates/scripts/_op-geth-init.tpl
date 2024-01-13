#!/bin/sh

if [ ! -f /root/.ethereum/.is_initialized ]; then
  echo "Not initialized, proceeding with download..."
  {{- if contains "lz4" .Values.init.downloadUrl }}
  apk add lz4
  wget -qO- {{ .Values.init.downloadUrl }} | tar -I lz4 -xvf -
  {{- else if contains "zstd" .Values.init.downloadUrl }}
  apk add zstd
  wget -qO- {{ .Values.init.downloadUrl }} | tar -I zstd -xvf -
  {{- else }}
  wget -qO- {{ .Values.init.downloadUrl }} | tar -xvf -
  {{- end }}
  touch /root/.ethereum/.is_initialized
else
  echo "Already initialized, skipping."
fi