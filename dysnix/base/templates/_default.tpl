{{/* vim: set filetype=mustache: */}}
{{/*
Render all resources
Usage:
  {{ include "base.all" $) }}
*/}}
{{- define "base.all" -}}
  {{- include "base.default.pod" . -}}
{{- end -}}

{{/*
Renders the default pod
Usage:
  {{ include "base.default.pod" $ }}
*/}}
{{- define "base.default.pod" -}}
  {{- $pod := .Values.defaultPod -}}
  {{- if $pod.enabled -}}
    {{- template "base.lib.validate" (dict "template" "base.validate.controllerSupported" "controller" $pod.controller "context" .) -}}
    {{- include (printf "base.%s" $pod.controller) (dict "value" .Values "component" "_default" "context" .) -}}
  {{- end -}}
{{- end -}}
