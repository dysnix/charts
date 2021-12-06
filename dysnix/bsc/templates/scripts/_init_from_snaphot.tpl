#!/usr/bin/env sh
set -ex # -e exits on error

DATA_DIR="{{ .Values.bsc.base_path }}"
TEST_FILE="${DATA_DIR}/.initialized"
SNAPSHOT_URL="{{ .Values.bsc.snapshotUrl }}"

{{- if .Values.bsc.forceInitFromSnapshot }}
    rm -f ${TEST_FILE}
{{- end }}

if [ -f ${TEST_FILE} ]; then
    echo "Blockchain already initialized. Exiting..."
    exit 0
fi

# Cleanup
rm -rf ${DATA_DIR}/geth

# Download & extract snapshot
# special handling of zstd
if [[ "${SNAPSHOT_URL}" =~ "\.zst$" ]]; then
  wget ${SNAPSHOT_URL} -O - | tar --zstd --overwrite -x -C ${DATA_DIR}
else
  wget ${SNAPSHOT_URL} -O - | tar --overwrite -x -C ${DATA_DIR}
fi


# Mark data dir as initialized
touch ${TEST_FILE}
