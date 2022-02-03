#!/usr/bin/env sh
set -ex # -e exits on error

# env required
# S3_ENDPOINT_URL # f.e. "https://storage.googleapis.com"
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

DATA_DIR="{{ .Values.bsc.base_path }}"
CHAINDATA_DIR="${DATA_DIR}/geth/chaindata"
INITIALIZED_FILE="${DATA_DIR}/.initialized"
#without gs:// or s3://, just a bucket name and path
INDEX_URL="{{ .Values.bsc.initFromGCS.indexUrl }}"
S5CMD=/s5cmd
EXCLUDE_ANCIENT='--exclude "*.cidx" --exclude "*.ridx" --exclude "*.cdat" --exclude "*.rdat"'
EXCLUDE_STATE='--exclude "*.ldb"'
INDEX="index"
S_UPDATING="/updating"
S_TIMESTAMP="/timestamp"
S_STATE_URL="/state_url"
S_ANCIENT_URL="/ancient_url"
S_STATS="/stats"

{{- if .Values.bsc.forceInitFromSnapshot }}
rm -f "${INITIALIZED_FILE}"
{{- end }}

if [ -f "${INITIALIZED_FILE}" ]; then
    echo "Blockchain already initialized. Exiting..."
    exit 0
fi

# we need to create temp files
cd /tmp

# get index of source base dirs
${S5CMD} cp "s3://${INDEX_URL}" "${INDEX}"

# get the most fresh datadir
# prune time is ignored here, we assume that all datadirs are pruned frequently enough
GCS_BASE_URL=""
MAX_TIMESTAMP=1
for _GCS_BASE_URL in $(cat ${INDEX});do
  _TIMESTAMP_URL="${_GCS_BASE_URL}${S_TIMESTAMP}"
  _TIMESTAMP=$(${S5CMD} cat s3://${_TIMESTAMP_URL})
  if [ "${_TIMESTAMP}" -gt "${MAX_TIMESTAMP}" ];then
    GCS_BASE_URL="${_GCS_BASE_URL}"
    MAX_TIMESTAMP=${_TIMESTAMP}
  fi
done

if [ "${GCS_BASE_URL}" == "" ];then
  echo "Fatal: cannot pick up correct base url, exiting"
  exit 1
fi


UPDATING_URL="${GCS_BASE_URL}${S_UPDATING}"
TIMESTAMP_URL="${GCS_BASE_URL}${S_TIMESTAMP}"
STATS_URL="${GCS_BASE_URL}${S_STATS}"

# get state and ancient sources
STATE_URL="${GCS_BASE_URL}${S_STATE_URL}"
ANCIENT_URL="${GCS_BASE_URL}${S_ANCIENT_URL}"


STATE_SRC="$(${S5CMD} cat s3://${STATE_URL})"
ANCIENT_SRC="$(${S5CMD} cat s3://${ANCIENT_URL})"
REMOTE_STATS="$(${S5CMD} cat s3://${STATS_URL})"

# create dst dirs
mkdir -p "${CHAINDATA_DIR}/ancient"

# save sync source
echo "${GCS_BASE_URL}" > "${DATA_DIR}/source"

set +e

# some background monitoring for humans
set +x
while true;do
  INODES=$(df -Phi ${DATA_DIR} | tail -n 1 | awk '{print $3}')
  SIZE=$(df -P -BG ${DATA_DIR} | tail -n 1 | awk '{print $3}')G
  echo -e "$(date -Iseconds) | SOURCE TOTAL ${REMOTE_STATS} | DST USED Inodes:\t${INODES} Size:\t${SIZE}"
  sleep 2
done &
MON_PID=$!
set -x

# get start and stop timestamps from the cloud
UPDATING_0="$(${S5CMD} cat s3://${UPDATING_URL})"
TIMESTAMP_0="$(${S5CMD} cat s3://${TIMESTAMP_URL})"


# we're ready to perform actual data sync

# we're done when both are true
# 1) start and stop timestamps did not changed during data sync - no process started or finished updating the cloud
# 2) 0 objects copied
SYNC=2
CLEANUP=1
while [ "${SYNC}" -gt 0 ] ; do

    # Cleanup
    if [ ${CLEANUP} -eq 1 ];then
      echo "$(date -Iseconds) Cleaning up local dir ..."
      mkdir -p ${DATA_DIR}/geth
      mv ${DATA_DIR}/geth ${DATA_DIR}/geth.old && rm -rf ${DATA_DIR}/geth.old &
      CLEANUP=0
    fi

    # sync from cloud to local disk, without removing existing [missing in the cloud] files
    # run multiple syncs in background

    # we don't wanna sync ancient data here
    time ${S5CMD} cp -n -s -u ${EXCLUDE_ANCIENT} s3://${STATE_SRC}/* ${CHAINDATA_DIR}/ > cplist_state.txt &
    STATE_CP_PID=$!
    time nice ${S5CMD} cp -n -s -u --part-size 200 --concurrency 2 ${EXCLUDE_STATE} s3://${ANCIENT_SRC}/* ${CHAINDATA_DIR}/ancient/ > cplist_ancient.txt &
    ANCIENT_CP_PID=$!

    # wait for all syncs to complete
    # TODO any errors handling here?
    wait ${STATE_CP_PID} ${ANCIENT_CP_PID}

    # get start and stop timestamps from the cloud after sync
    UPDATING_1="$(${S5CMD} cat s3://${UPDATING_URL})"
    TIMESTAMP_1="$(${S5CMD} cat s3://${TIMESTAMP_URL})"

    # compare timestamps before and after sync
    if [ "${UPDATING_0}" -eq "${UPDATING_1}" ] && [ "${TIMESTAMP_0}" -eq "${TIMESTAMP_1}" ];then
      echo "Timestamps are equal"
      echo -e "U_0=${UPDATING_0}\tU_1=${UPDATING_1},\tT_0=${TIMESTAMP_0}\tT_1=${TIMESTAMP_1}"
      let SYNC=SYNC-1
    else
      echo "Timestamps changed, running sync again ..."
      echo -e "U_0=${UPDATING_0}\tU_1=${UPDATING_1},\tT_0=${TIMESTAMP_0}\tT_1=${TIMESTAMP_1}"
      # end  timestamps -> begin timestamps
      UPDATING_0=${UPDATING_1}
      TIMESTAMP_0=${TIMESTAMP_1}
      SYNC=2
      {{- if .Values.bsc.initFromGCS.fullResyncOnSrcUpdate }}
      # hack until we resolve sync up without full destination cleanup
      CLEANUP=1
      {{- end }}
      continue
    fi

    # stop monitoring
    if [ ${MON_PID} -ne 0 ];then
      kill ${MON_PID}
      MON_PID=0
    fi

    # get number of objects copied
    CP_OBJ_NUMBER_STATE=$(wc -l <  cplist_state.txt )
    CP_OBJ_NUMBER_ANCIENT=$(wc -l < cplist_ancient.txt )
    #  0 objects copied ?
    if [ "${CP_OBJ_NUMBER_STATE}" -eq 0 ] && [ "${CP_OBJ_NUMBER_ANCIENT}" -eq 0 ];then
      echo -e "State objects copied:\t${CP_OBJ_NUMBER_STATE}, ancient objects copied:\t${CP_OBJ_NUMBER_ANCIENT}"
      let SYNC=SYNC-1
    else
      echo -e "State objects copied:\t${CP_OBJ_NUMBER_STATE}, ancient objects copied:\t${CP_OBJ_NUMBER_ANCIENT}, running sync again ... "
      SYNC=2
      continue
    fi
done

# Mark data dir as initialized
touch ${INITIALIZED_FILE}
