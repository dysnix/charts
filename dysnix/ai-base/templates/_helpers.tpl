{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper App image name
*/}}
{{- define "base.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "base.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "base.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Set App PVC
*/}}
{{- define "base.pvc" -}}
{{- .Values.persistence.existingClaim | default (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Return  the proper Storage Class
*/}}
{{- define "base.storageClass" -}}
{{- include "common.storage.class" (dict "persistence" .Values.persistence "global" .Values.global) -}}
{{- end -}}

{{/*
Choose port name based on .port .targetPort. Fallbacks to "app".

Examples:
  {{- include "base.service.defaultPortName" (dict "port" "80" "targetPort" "8080") }}
  {{- include "base.service.defaultPortName" (dict "port" "80" "targetPort" "api") }}
*/}}
{{- define "base.service.defaultPortName" -}}
{{- $targetPort := .targetPort | default .port -}}
{{- if regexMatch "^[0-9]+$" ($targetPort | toString) -}}
app
{{- else -}}
{{ $targetPort }}
{{- end -}}
{{- end -}}

{{- define "base.deployment.containerPorts" -}}
{{- $default := (include "base.deployment.defaultPorts" .) | fromYaml | default (dict "ports" list) }}
{{- (concat ($default.ports | default list) .Values.containerPorts) | toYaml }}
{{- end }}

{{- define "base.deployment.defaultPorts" -}}
ports:
{{- if .Values.profiling.enabled }}
  - name: profiling
    containerPort: {{ .Values.profiling.port | default 6060 }}
    protocol: TCP
{{- end }}
{{- if .Values.monitoring.enabled }}
  - name: metrics
    protocol: TCP
    port: {{ .Values.monitoring.port | default 8080 }}
{{- end }}
{{- end }}