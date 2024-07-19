#!/usr/bin/env sh
set -ex # -e exits on error

# env required
# S3_ENDPOINT_URL # f.e. "https://storage.googleapis.com"
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

DATA_DIR="{{ .Values.bsc.base_path }}"
GETH_DIR="${DATA_DIR}/geth"
CHAINDATA_DIR="${GETH_DIR}/chaindata"
STATE_TMP_DIR="${GETH_DIR}/state_tmp"
ANCIENT_TMP_DIR="${GETH_DIR}/ancient_tmp"
INITIALIZED_FILE="${DATA_DIR}/.initialized"
OUT_OF_SPACE_FILE="${DATA_DIR}/.out_of_space"
#without gs:// or s3://, just a bucket name and path
INDEX_URL="{{ .Values.bsc.initFromGCS.indexUrl }}"
GCS_BASE_URL="{{ .Values.bsc.initFromGCS.baseUrlOverride }}"
S5CMD=/s5cmd
INDEX="index"
S_UPDATING="/updating"
S_TIMESTAMP="/timestamp"
S_STATE_URL="/state_url"
S_ANCIENT_URL="/ancient_url"
S_STATS="/stats"
MAX_USED_SPACE_PERCENT={{ .Values.bsc.initFromGCS.maxUsedSpacePercent }}
S5CMD_STATE_OPTS=""
S5CMD_ANCIENT_OPTS="--part-size 200 --concurrency 2"
{{- if .Values.bsc.pruneancient }}
# we expect the source snapshot to be pruned, thus we may increase workers from default 256 to speed things up
# as ancient dir has less than 100 files with the size less than 10GB, we want to run full speed on state dir instead
S5CMD_STATE_OPTS="--numworkers {{ .Values.bsc.initFromGCS.boostStateCopyWorkers }}"
{{- end }}

# allow container interrupt
trap "{ exit 1; }" INT TERM

{{- if .Values.bsc.forceInitFromSnapshot }}
rm -f "${INITIALIZED_FILE}" "${OUT_OF_SPACE_FILE}"
{{- end }}

if [ -f "${INITIALIZED_FILE}" ]; then
    echo "Blockchain already initialized. Exiting..."
    exit 0
fi

if [ -f "${OUT_OF_SPACE_FILE}" ]; then
    echo "Seems, we're out of space. Exiting with an error ..."
    cat "${OUT_OF_SPACE_FILE}"
    exit 2
fi

# we need to create temp files
cd /tmp

if [ "${GCS_BASE_URL}" == "" ];then
  # get index of source base dirs
  ${S5CMD} cp "s3://${INDEX_URL}" "${INDEX}"

  # get the most fresh datadir
  # prune time is ignored here, we assume that all datadirs are pruned frequently enough
  MAX_TIMESTAMP=1
  for _GCS_BASE_URL in $(cat ${INDEX});do
    _TIMESTAMP_URL="${_GCS_BASE_URL}${S_TIMESTAMP}"
    _TIMESTAMP=$(${S5CMD} cat s3://${_TIMESTAMP_URL})
    if [ "${_TIMESTAMP}" -gt "${MAX_TIMESTAMP}" ];then
      GCS_BASE_URL="${_GCS_BASE_URL}"
      MAX_TIMESTAMP=${_TIMESTAMP}
    fi
  done
else
  echo "Using overridden base URL: ${GCS_BASE_URL}"
fi
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

# we're done when all are true
# 1) start and stop timestamps did not changed during data sync - no process started or finished updating the cloud
# 2) start timestamp is before stop timestamp - no process is in progress updating the cloud
# 3) 0 objects copied
SYNC=2
CLEANUP=1
while [ "${SYNC}" -gt 0 ] ; do

    # Cleanup
    if [ ${CLEANUP} -eq 1 ];then
      echo "$(date -Iseconds) Cleaning up local dir ${GETH_DIR} ..."
      mkdir -p "${GETH_DIR}"
      mv "${GETH_DIR}" "${GETH_DIR}.old" && rm -rf "${GETH_DIR}.old" &
      CLEANUP=0
    fi

    # sync from cloud to local disk, with removing existing [missing in the cloud] files
    # run multiple syncs in background

    time ${S5CMD} sync --delete ${S5CMD_STATE_OPTS} s3://${STATE_SRC}/* ${STATE_TMP_DIR}/ > cplist_state.txt &
    STATE_CP_PID=$!
    time nice ${S5CMD} sync --delete ${S5CMD_ANCIENT_OPTS} s3://${ANCIENT_SRC}/* ${ANCIENT_TMP_DIR}/ > cplist_ancient.txt &
    ANCIENT_CP_PID=$!

    # wait for all syncs to complete
    # shell tracks all sub-processes and stores exit codes internally
    # it's not required to stay in wait state for all background processes at the same time
    # we'll handle these processes sequentially
    wait ${STATE_CP_PID}
    STATE_CP_EXIT_CODE=$?
    wait ${ANCIENT_CP_PID}
    ANCIENT_CP_EXIT_CODE=$?

    # let's handle out of disk space specially, thus we don't re-try, just stuck here if disk usage is high
    VOLUME_USAGE_PERCENT=$(df "${DATA_DIR}" | tail -n 1 | awk '{print $5}'|tr -d %)
    if [ "${VOLUME_USAGE_PERCENT}" -gt "${MAX_USED_SPACE_PERCENT}" ];then
      set +x
      # stop monitoring
      if [ ${MON_PID} -ne 0 ];then kill ${MON_PID};MON_PID=0; fi
      # out of inodes error is "handled" by "set -e"
      echo "We're out of disk space. Marking ${DATA_DIR} as out-of-space and exiting. Check the source snapshot size" | tee -a "${OUT_OF_SPACE_FILE}"
      echo "Source snapshot size ${REMOTE_STATS}" | tee -a "${OUT_OF_SPACE_FILE}"
      echo "Disk usage is ${VOLUME_USAGE_PERCENT}%" | tee -a "${OUT_OF_SPACE_FILE}"
      df -P -BG "${DATA_DIR}" | tee -a "${OUT_OF_SPACE_FILE}"
      exit 2
    fi
    # s5cmd uses 0 for success and 1 for any errors
    # no errors - we're good to go
    # any errors - retry the download
    # all the exit codes have to be 0
    if [ "${STATE_CP_EXIT_CODE}" -ne "0" ] || [ "${ANCIENT_CP_EXIT_CODE}" -ne "0" ];then
      echo "s5cmd sync returned non-zero, retrying sync after the short sleep"
      # wait some time to not spam with billable requests too frequently
      sleep 60
      SYNC=2
      continue
    fi
    # get start and stop timestamps from the cloud after sync
    UPDATING_1="$(${S5CMD} cat s3://${UPDATING_URL})"
    TIMESTAMP_1="$(${S5CMD} cat s3://${TIMESTAMP_URL})"

    # compare timestamps before and after sync
    # ensuring start timestamp is earlier than stop timestamp
    if [ "${UPDATING_0}" -eq "${UPDATING_1}" ] && [ "${TIMESTAMP_0}" -eq "${TIMESTAMP_1}" ] && [ "${TIMESTAMP_1}" -gt "${UPDATING_1}" ] ;then
      echo "Timestamps did not changed and start timestamp is before stop timestamp"
      echo -e "U_0=${UPDATING_0}\tU_1=${UPDATING_1},\tT_0=${TIMESTAMP_0}\tT_1=${TIMESTAMP_1}"
      let SYNC=SYNC-1
    else
      echo "Source timestamps changed or start timestamp is after stop timestamp, running sync again ..."
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

    # stop monitoring, we don't expect massive data copying
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

set -e
# prepare geth datadir from tmp dirs
mv "${STATE_TMP_DIR}" "${CHAINDATA_DIR}"
rm -rf "${CHAINDATA_DIR}/ancient"
mv "${ANCIENT_TMP_DIR}" "${CHAINDATA_DIR}/ancient"

# Mark data dir as initialized
touch ${INITIALIZED_FILE}
