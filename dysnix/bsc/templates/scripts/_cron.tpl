#!/usr/bin/env sh

# possible values are
# "sync" to trigger sync-to-gcs
# "prune" to trigger prune
MODE="${1}"
POD_NAME={{ include "bsc.fullname" . }}-0
CONFIGMAP_NAME="{{ .Release.Name }}-env"
KUBECTL=$(which kubectl)
# wait timeout, f.e "30s"
WAIT_TIMEOUT="${2}"
PATCH_DATA=""

check_ret(){
        ret="${1}"
        msg="${2}"
        # allow to override exit code, default value is ret
        exit_code=${3:-${ret}}
        if [ ! "${ret}" -eq 0 ];then
                echo "${msg}"
                echo "return code ${ret}, exit code ${exit_code}"
                exit "${exit_code}"
        fi
}

# input data checking
[ "${MODE}" = "prune" ] || [ "${MODE}" = "sync" ]
check_ret $? "$(date -Iseconds) Mode value \"${MODE}\" is incorrect, abort"

# wait for pod to become ready
echo "$(date -Iseconds) Waiting ${WAIT_TIMEOUT} for pod ${POD_NAME} to become ready ..."
${KUBECTL} wait --timeout="${WAIT_TIMEOUT}" --for=condition=Ready pod "${POD_NAME}"
ret=$?
# exit code override to "success"
check_ret "${ret}" "$(date -Iseconds) Pod ${POD_NAME} is not ready, nothing to do, exiting" 0

# ensuring pod is not terminating now
# https://github.com/kubernetes/kubernetes/issues/22839
echo "$(date -Iseconds) Checking for pod ${POD_NAME} to not terminate ..."
DELETION_TIMESTAMP=$(${KUBECTL} get -o jsonpath='{.metadata.deletionTimestamp}' pod "${POD_NAME}")
ret=$?
check_ret "${ret}" "$(date -Iseconds) Cannot get pod ${POD_NAME}, abort"

# empty timestamp means that pod is not terminating now
if [ "${DELETION_TIMESTAMP}" = "" ];then
  # we're good to go
  echo "$(date -Iseconds) Pod ${POD_NAME} is ready, continuing"

  case "${MODE}" in
  "sync")
    echo "$(date -Iseconds) Patching configmap ${CONFIGMAP_NAME} to enable sync and disable prune"
    # disable prune, enable sync-to-gcs
    PATCH_DATA='{"data":{"BSC_PRUNE":"False","SYNC_TO_GCS":"True"}}'
    ;;
  "prune")
    echo "$(date -Iseconds) Patching configmap ${CONFIGMAP_NAME} to enable prune and disable sync"
    # disable sync-to-gcs, enable prune
    PATCH_DATA='{"data":{"BSC_PRUNE":"True","SYNC_TO_GCS":"False"}}'
    ;;
  "*")
     check_ret 1 "$(date -Iseconds) Mode value \"${MODE}\" is incorrect, abort"
     ;;
  esac
  ${KUBECTL} patch configmap "${CONFIGMAP_NAME}"  --type merge --patch ${PATCH_DATA}
  ret=$?
  check_ret "${ret}" "$(date -Iseconds) Fatal: cannot patch configmap ${CONFIGMAP_NAME}, abort"

  echo "$(date -Iseconds) Deleting pod ${POD_NAME} to trigger action inside init container ..."
  # delete the pod to trigger action inside init container
  ${KUBECTL} delete pod "${POD_NAME}" --wait=false
  ret=$?
  check_ret "${ret}" "$(date -Iseconds) Fatal: cannot delete pod ${POD_NAME}, abort"
  echo "$(date -Iseconds) Pod ${POD_NAME} deleted successfully, exiting. Check pod logs after respawn."
else
  # pod is terminating now, try later on next iteration
  echo "$(date -Iseconds) Pod ${POD_NAME} is terminating now, nothing to do, exiting"
  exit 0
fi
