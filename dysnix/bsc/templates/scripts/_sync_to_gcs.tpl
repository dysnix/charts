#!/usr/bin/env sh
set -ex # -e exits on error

# env required
# S3_ENDPOINT_URL # f.e. "https://storage.googleapis.com"
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# SYNC_TO_GCS True or any other value

# enable sync via env
if [ "${SYNC_TO_GCS}" != "True" ];then
  exit 0
fi

DATA_DIR="{{ .Values.bsc.base_path }}"
INITIALIZED_FILE="${DATA_DIR}/.initialized"
CHAINDATA_DIR="${DATA_DIR}/geth/chaindata"
#without gs:// or s3://, just a bucket name and path
GCS_BASE_URL="{{ .Values.bsc.syncToGCS.baseUrl }}"
# GSUTIL=$(which gsutil)

S5CMD=/s5cmd
CPLOG="${DATA_DIR}/cplog.txt"
CPLIST="${DATA_DIR}/cplist.txt"
RMLOG="${DATA_DIR}/rmlog.txt"
RMLIST="${DATA_DIR}/rmlist.txt"

# s5cmd excludes just by file extension, not by file path
EXCLUDE_ANCIENT="--exclude *.cidx --exclude *.ridx --exclude *.cdat --exclude *.rdat"
EXCLUDE_STATE="--exclude *.ldb --exclude *.sst"

S_UPDATING="/updating"
S_TIMESTAMP="/timestamp"
S_STATE_URL="/state_url"
S_ANCIENT_URL="/ancient_url"
S_STATS="/stats"

if [ "${GCS_BASE_URL}" == "" ];then
  echo "Fatal: cannot use empty base url, exiting"
  exit 1
fi

# find a file older than 30 minutes.
# 0 - file not found, it means that file is fresh or missing in the filesystem or some find error
# other value - file is found and is older than 30 minutes

IS_INITIALIZED_FILE_OLD=$(find "${INITIALIZED_FILE}" -type f -mmin +30|wc -l)

if [ "${IS_INITIALIZED_FILE_OLD}" == "0" ]; then
    echo "Blockchain initialized recently, skipping the upload. Exiting..."
    exit 0
fi

# we need to create temp files
cd /tmp

# get timestamp, state and ancient DSTs
UPDATING_URL="${GCS_BASE_URL}${S_UPDATING}"
TIMESTAMP_URL="${GCS_BASE_URL}${S_TIMESTAMP}"
STATS_URL="${GCS_BASE_URL}${S_STATS}"

STATE_URL="${GCS_BASE_URL}${S_STATE_URL}"
ANCIENT_URL="${GCS_BASE_URL}${S_ANCIENT_URL}"

STATE_DST="$(${S5CMD} cat s3://${STATE_URL})"
ANCIENT_DST="$(${S5CMD} cat s3://${ANCIENT_URL})"

# mark begin of sync in the cloud
date +%s > updating
${S5CMD} cp updating "s3://${UPDATING_URL}"

# we're ready to perform actual data copy

# sync from local disk to cloud with removing existing [missing on local disk] files
# run multiple syncs in background
# sync is recursive by default, thus we need to exclude ancient data here
time ${S5CMD} --stat --log error sync --delete ${EXCLUDE_ANCIENT} "${CHAINDATA_DIR}/" "s3://${STATE_DST}/" &
STATE_CP_PID=$!
time nice ${S5CMD} --stat --log error sync --delete --part-size 200 --concurrency 2 ${EXCLUDE_STATE} "${CHAINDATA_DIR}/ancient/" "s3://${ANCIENT_DST}/" &
ANCIENT_CP_PID=$!
# Wait for each specified child process and return its termination status
# errors are "handled" by "set -e"
wait ${STATE_CP_PID}
wait ${ANCIENT_CP_PID}

# update timestamp
# TODO store timestamp inside readinnes check and use it instead of now()
date +%s > timestamp
${S5CMD} cp timestamp "s3://${TIMESTAMP_URL}"

# update stats
INODES=$(df -Phi "${DATA_DIR}" | tail -n 1 | awk '{print $3}')
# force GB output
SIZE=$(df -P -BG "${DATA_DIR}" | tail -n 1 | awk '{print $3}')G
echo -ne "Inodes:\t${INODES} Size:\t${SIZE}" > stats
${S5CMD} cp stats "s3://${STATS_URL}"
