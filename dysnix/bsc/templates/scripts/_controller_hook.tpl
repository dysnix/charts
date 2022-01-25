#!/usr/bin/env bash

# This is needed to work-around GKE local SSD scale up issue https://github.com/kubernetes/autoscaler/issues/2145

# watch for scale-related changes in the specified controller
# in scale up case -> scale up secondary controller to the same replica value
# in scale down case -> scale down secondary controller to 0

controller={{ .Values.controller }}
{{- if eq  .Values.controller "StatefulSet" }}
apiVersion="apps/v1"
{{- end }}
{{- if eq .Values.controller "CloneSet" }}
apiVersion="apps.kruise.io/v1alpha1"
{{- end }}

watchName="OnModified${controller}"
debugLog="/tmp/debug.log"

if [[ $1 == "--config" ]] ; then
  cat <<EOF
configVersion: v1
kubernetes:
- name: "${watchName}"
  apiVersion: ${apiVersion}
  kind: $controller
  executeHookOnEvent: ["Modified"]
  labelSelector:
    matchLabels:
      app.kubernetes.io/name: {{ include "bsc.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
  namespace:
    nameSelector:
      matchNames: ["{{ .Release.Namespace }}"]
  jqFilter: ".spec.replicas"
EOF
else
	# ignore Synchronization for simplicity
	type=$(jq -r '.[0].type' "${BINDING_CONTEXT_PATH}")
	if [[ "${type}" == "Synchronization" ]] ; then
	  echo Got Synchronization event
	  exit 0
	fi
  	ARRAY_COUNT=$(jq -r '. | length-1' "${BINDING_CONTEXT_PATH}")
	for i in $(seq 0 "${ARRAY_COUNT}");do
		bindingName=$(jq -r ".[$i].binding" "${BINDING_CONTEXT_PATH}")
		resourceEvent=$(jq -r ".[$i].watchEvent" "${BINDING_CONTEXT_PATH}")
		resourceName=$(jq -r ".[$i].object.metadata.name" "${BINDING_CONTEXT_PATH}")
		if [[ "${bindingName}" == "${watchName}" && "${resourceEvent}" == "Modified" ]] ; then
		  	echo "${controller} ${resourceName} was scaled"
		  	newReplicas=$(jq -r ".[$i].object.spec.replicas" "${BINDING_CONTEXT_PATH}")
        oldReplicas=$(jq -r ".[$i].object.status.replicas" "${BINDING_CONTEXT_PATH}")
        addController=$(jq -r ".[$i].object.metadata.annotations.additionalControllerName" "${BINDING_CONTEXT_PATH}")
        namespace=$(jq -r ".[$i].object.metadata.namespace" "${BINDING_CONTEXT_PATH}")
        if [[ "${newReplicas}" -gt "${oldReplicas}" ]];then
          echo "$(date -Iseconds) scale UP ${controller} ${addController}, new=${newReplicas}, old=${oldReplicas}" | tee -a "${debugLog}"
          kubectl --namespace "${namespace}" scale "${controller}" "${addController}" --replicas="${newReplicas}"
        fi
        if [[ "${newReplicas}" -lt "${oldReplicas}" ]];then
          echo "$(date -Iseconds) scale DOWN ${controller} ${addController} to 0, new=${newReplicas}, old=${oldReplicas}" | tee -a "${debugLog}"
          kubectl --namespace "${namespace}" scale "${controller}" "${addController}" --replicas=0
        fi
		fi
	done
#	echo  "$(date -Iseconds)"  >> "${debugLog}"
#	cat "${BINDING_CONTEXT_PATH}" | jq . >> "${debugLog}"
fi
