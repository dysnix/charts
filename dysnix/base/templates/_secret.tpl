{{/* vim: set filetype=mustache: */}}

{{/*
Usage:
  {{- include "base.secret" (dict "value" .Values.or.path "name" "optional" "component" "optional" "context" $) -}}

Params:
  value - [dict] .Values or path to component values
  context - render context (root is propogated - $)
  name - (optional) specifies the ServiceAccount name supplement
  component - (optional) specifies the component name (used for naming and labeling)
*/}}
{{- define "base.secret" -}}

{{- $context := .context -}}
{{- $value := .value -}}
{{- $secret := $value | merge dict | dig "secret" dict -}}
{{- $component := include "base.lib.component" (dict "value" $value "component" .component) -}}

{{/* Validations */}}
{{- template "base.lib.validate" (dict "template" "base.validate.context" "context" $context) -}}

{{- if and $secret.create (or ($secret.data | default dict) ($secret.stringData | default dict)) }}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "base.lib.fullname" (dict "value" $value "name" .name "component" $component "context" $context) }}
  labels: {{- include "base.labels.standard" (dict "value" $value "component" $component "context" $context) | nindent 4 }}
  {{- if or $secret.annotations $context.Values.commonAnnotations }}
  annotations:
    {{- with (include "common.tplvalues.render" (dict "value" $context.Values.commonAnnotations "context" $context)) }}
      {{ . | nindent 4 }}
    {{- end }}
    {{- with (include "common.tplvalues.render" (dict "value" $secret.annotations "context" $context)) }}
      {{ . | nindent 4 }}
    {{- end }}
  {{- end }}
type: {{ $secret.type | default "Opaque" }}
{{- with $secret.data }}
data:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $secret.stringData }}
stringData:
  {{- include "common.tplvalues.render" (dict "value" . "context" $context) | nindent 2 }}
{{- end }}

{{- end -}}
{{- end -}}
