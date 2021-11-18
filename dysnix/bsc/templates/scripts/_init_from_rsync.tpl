#!/usr/bin/env sh
set -ex # -e exits on error

DATA_DIR="{{ .Values.bsc.base_path }}"
TEST_FILE="${DATA_DIR}/.initialized"
SNAPSHOT_URL="{{ .Values.bsc.snapshotRsyncUrl }}"

# get statefulset pod number from pre-defined env var
STS_POD_NUMBER=$(echo $MY_POD_NAME|sed -r 's/^.+\-([0-9]+)$/\1/')
#generate variable name to check for URL override, it should be like SNAPSHOT_URL_123, if present
VAR_NAME=\$SNAPSHOT_URL_${STS_POD_NUMBER}
#get the URL, if any
NEW_URL=$(eval echo $VAR_NAME)
if [ ! -z "$NEW_URL" ];then
  SNAPSHOT_URL=$NEW_URL
fi
{{- if .Values.bsc.forceInitFromSnapshot }}
    rm -f ${TEST_FILE}
{{- end }}

if [ -f ${TEST_FILE} ]; then
    echo "Blockchain already initialized. Exiting..."
    exit 0
fi

rsync -av ${SNAPSHOT_URL}/ ${DATA_DIR}/
# one more time to catch up
rsync -av ${SNAPSHOT_URL}/ ${DATA_DIR}/

# Mark data dir as initialized
touch ${TEST_FILE}
