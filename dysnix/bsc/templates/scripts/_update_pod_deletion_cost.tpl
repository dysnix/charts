#!/usr/bin/env sh

# this script updates "pod-deletion-cost" pod annotation based on disk usage

# required env
# MY_POD_NAME - pod name to annotate

# get used space from this dir's mount point
DATA_DIR="${1}"
# sleep between annotate iterations, in 10*second
INTERVAL="${2}"

KUBECTL=$(which kubectl)
ANNOTATION=""

# allow container interrupts
trap "{ exit 1; }" INT TERM

while [ true ]; do
  # get dir's mount point usage in MB
  SIZE=$(df -P -BM "${DATA_DIR}" | tail -n 1 | awk '{print $3}'|sed 's/M//g')
  # use negative values, the bigger is the disk usage the lower is the pod deletion cost
  # thus the most "heavy" pod will be removed first
  ANNOTATION="controller.kubernetes.io/pod-deletion-cost=-${SIZE}"
  ${KUBECTL} annotate --overwrite=true pod "${MY_POD_NAME}" "${ANNOTATION}"
  ret=$?
  if [ ${ret} -eq 0 ];then
    echo "$(date -Iseconds) Annotated pod ${MY_POD_NAME} with ${ANNOTATION}"
  else
    echo "$(date -Iseconds) Error annotating pod ${MY_POD_NAME} with ${ANNOTATION}"
  fi
  {{- if and .Values.autoScaleTrigger.enabled (eq .Values.controller "CloneSet") }}
  ADDON_POD_NAME=$(${KUBECTL} get pods --namespace="${MY_POD_NAMESPACE}" --selector=bsc/role="auto-scale-trigger" --field-selector=spec.nodeName="${MY_NODE_NAME}" -o name)
  ret=$?
  if [ ${ret} -eq 0 ];then
    ${KUBECTL} annotate --overwrite=true "${ADDON_POD_NAME}" "${ANNOTATION}"
    ret0=$?
    if [ ${ret0} -eq 0 ];then
      echo "$(date -Iseconds) Annotated ${ADDON_POD_NAME} with ${ANNOTATION}"
    else
      echo "$(date -Iseconds) Error annotating ${ADDON_POD_NAME} with ${ANNOTATION}"
    fi
  fi
  {{- end }}
  # we need to sleep <short-delay> inside cycle to handle pod termination w/o delays
  for i in $(seq 2 "${INTERVAL}");do sleep 10;done
done
