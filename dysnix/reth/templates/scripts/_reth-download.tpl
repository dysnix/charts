#!/usr/bin/env sh
set -e

INITIALIZED_FILE="{{ .Values.config.datadir }}/.initialized"
DATADIR="{{ .Values.config.datadir }}"
CHAIN="{{ .Values.config.chain }}"

# Skip if already initialized
if [ -f "$INITIALIZED_FILE" ]; then
  echo "Already initialized (${INITIALIZED_FILE} exists). Skipping download."
  exit 0
fi

echo "Starting reth download for chain=${CHAIN}..."

TERMINATED=false
reth download \
  --datadir="$DATADIR" \
  --chain="$CHAIN" \
{{- if .Values.init.download.nightly }}
  -y --resumable \
{{- end }}
{{- with .Values.init.download.extraArgs }}
{{- range . }}
  {{ tpl . $ }} \
{{- end }}
{{- end }}
&
PID=$!
trap 'TERMINATED=true; kill -TERM $PID; wait $PID' TERM INT
wait $PID
STATUS=$?

if [ "$TERMINATED" = "false" ] && [ $STATUS -eq 0 ]; then
  touch "$INITIALIZED_FILE"
  echo "Download complete."
fi
exit $STATUS
