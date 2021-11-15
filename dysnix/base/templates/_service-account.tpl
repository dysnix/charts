{{/* vim: set filetype=mustache: */}}

{{/*
Usage:
  {{- include "base.serviceAccount" (dict "Values" .Values.or.path "name" "optional" "component" "optional" "context" $) -}}

Params:
  value - [dict] .Values or path to component values
  context - render context (root is propogated - $)
  name - (optional) specifies the ServiceAccount name supplement
  component - (optional) specifies the component name (used for naming and labeling)
*/}}
{{- define "base.serviceAccount" -}}

{{- $context := .context -}}
{{- $value := .value -}}
{{- $sa := $value | merge dict | dig "serviceAccount" dict -}}
{{- $component := include "base.lib.component" (dict "value" $value "component" .component) -}}

{{/* Validations */}}
{{- template "base.lib.validate" (dict "template" "base.validate.context" "context" $context) -}}

{{- if $sa.create }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "base.lib.serviceAccountName" (dict "serviceAccount" $sa "name" .name "component" $component "context" $context) }}
  labels: {{- include "base.labels.standard" (dict "value" $value "component" $component "context" $context) | nindent 4 }}
  {{- if or $sa.annotations $context.Values.commonAnnotations }}
  annotations:
    {{- with (include "common.tplvalues.render" (dict "value" $context.Values.commonAnnotations "context" $context)) }}
      {{ . | nindent 4 }}
    {{- end }}
    {{- with (include "common.tplvalues.render" (dict "value" $sa.annotations "context" $context)) }}
      {{ . | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end }}

{{- end -}}
