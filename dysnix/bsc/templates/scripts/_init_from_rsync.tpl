#!/usr/bin/env sh
set -ex # -e exits on error

DATA_DIR="{{ .Values.bsc.base_path }}"
TEST_FILE="${DATA_DIR}/.initialized"
SNAPSHOT_URL="{{ .Values.bsc.snapshotRsyncUrl }}"

{{- if .Values.bsc.forceInitFromSnapshot }}
    rm -f ${TEST_FILE}
{{- end }}

if [ -f ${TEST_FILE} ]; then
    echo "Blockchain already initialized. Exiting..."
    exit 0
fi

rsync -av ${SNAPSHOT_URL}/ ${DATA_DIR}/

# Mark data dir as initialized
touch ${TEST_FILE}
