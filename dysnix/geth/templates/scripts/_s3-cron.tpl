#!/usr/bin/env sh
# shellcheck disable=SC1083

MODE="$1"
WAIT_TIMEOUT="$2"
CONFIGMAP_NAME={{ include "geth.fullname" . }}-s3-config
KUBECTL=$(which kubectl)
PATCH_DATA=""
POD_NAME={{ include "geth.fullname" . }}-0

check_ret(){
        ret="$1"
        msg="$2"
        # allow to override exit code, default value is ret
        exit_code=${3:-${ret}}
        if [ ! "$ret" -eq 0 ]; then
                echo "$msg"
                echo "return code ${ret}, exit code ${exit_code}"
                exit "$exit_code"
        fi
}

check_pod_readiness() {
  # wait for pod to become ready
  echo "$(date -Iseconds) Waiting ${WAIT_TIMEOUT} for pod ${1} to become ready ..."
  "$KUBECTL" wait --timeout="$WAIT_TIMEOUT" --for=condition=Ready pod "$1"
  check_ret $? "$(date -Iseconds) Pod ${1} is not ready, nothing to do, exiting" 0

  # ensuring pod is not terminating now
  # https://github.com/kubernetes/kubernetes/issues/22839
  echo "$(date -Iseconds) Checking for pod ${1} to not terminate ..."
  deletion_timestamp=$("$KUBECTL" get -o jsonpath='{.metadata.deletionTimestamp}' pod "$1")
  check_ret $? "$(date -Iseconds) Cannot get pod ${1}, abort"

  if [ -z "$deletion_timestamp" ]; then
    echo "$(date -Iseconds) Pod ${1} is ready, continuing"
  else
    echo "$(date -Iseconds) Pod ${1} is terminating, try another time"
  fi
}

enable_sync() {
  echo "$(date -Iseconds) Patching configmap ${CONFIGMAP_NAME} to enable sync"
  PATCH_DATA='{"data":{"SYNC_TO_S3":"True"}}'
}

disable_sync() {
  echo "$(date -Iseconds) Patching configmap ${CONFIGMAP_NAME} to disable sync"
  PATCH_DATA='{"data":{"SYNC_TO_S3":"False"}}'
}

patch_configmap() {
  "$KUBECTL" patch configmap "$CONFIGMAP_NAME" --type merge --patch "$PATCH_DATA"
  check_ret $? "$(date -Iseconds) Fatal: cannot patch configmap ${CONFIGMAP_NAME}, abort"
}

delete_pod() {
  echo "$(date -Iseconds) Deleting pod ${1} to trigger action inside init container ..."
  # delete the pod to trigger action inside init container
  "$KUBECTL" delete pod "$1" --wait=false
  check_ret $? "$(date -Iseconds) Fatal: cannot delete pod ${1}, abort"
  echo "$(date -Iseconds) Pod ${1} deleted successfully, exiting. Check pod logs after restart."
}

main() {
  case "$MODE" in
  "enable_sync")
    check_pod_readiness "$POD_NAME"
    enable_sync
    patch_configmap
    delete_pod "$POD_NAME"
    ;;
  # intended to be run in sidecar after successful sync, don't interact with pod
  "disable_sync")
    disable_sync
    patch_configmap
    ;;
  "*")
    check_ret 1 "$(date -Iseconds) Mode value \"$MODE\" is incorrect, abort"
    ;;
  esac
}

main