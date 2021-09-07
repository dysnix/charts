{{/*
Main entrypoint for the base library chart. It will render all underlying templates based on the provided values.
*/}}
{{- define "base.all" -}}
{{- /* Build the templates */ -}}

{{- if .Values.persistence -}}
  {{- include "base.pvc" . }}
{{- end -}}

{{- if .Values.serviceAccount.create -}}
  {{- include "base.serviceAccount" . }}
{{- end -}}

{{- if .Values.controller.enabled }}
  {{- if eq .Values.controller.type "deployment" }}
    {{- include "base.deployment" . }}
  {{ else }}
    {{- fail (printf "Not a valid controller.type (%s)" .Values.controller.type) }}
  {{- end -}}
{{- end -}}

{{ include "base.hpa" . }}

{{ include "base.service" . }}

{{ include "base.ingress" . }}

{{ include "base.configMap" . }}

{{ include "base.secret" . }}

{{- end -}}
