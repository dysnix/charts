{{/* vim: set filetype=mustache: */}}

{{/*
Usage:
  {{- include "base.configMap" (dict "value" .Values.or.path "name" "optional" "component" "optional" "context" $) -}}

Params:
  value - [dict] .Values or path to component values
  context - render context (root is propogated - $)
  name - (optional) specifies the ServiceAccount name supplement
  component - (optional) specifies the component name (used for naming and labeling)
*/}}
{{- define "base.configMap" -}}

{{- $context := .context -}}
{{- $value := .value -}}
{{- $config := $value | merge dict | dig "configMap" dict -}}
{{- $component := include "base.lib.component" (dict "value" $value "component" .component) -}}

{{/* Validations */}}
{{- template "base.lib.validate" (dict "template" "base.validate.context" "context" $context) -}}

{{- if and $config.create ($config.data | default dict) }}
---
apiVersion: v1
kind: ConfigMap
immutable: {{ $config.immutable }}
metadata:
  name: {{ include "base.lib.fullname" (dict "value" $value "name" .name "component" $component "context" $context) }}
  labels: {{- include "base.labels.standard" (dict "value" $value "component" $component "context" $context) | nindent 4 }}
  {{- with (list $config.annotations $context.Values.commonAnnotations | compact)  }}
  annotations: {{- include "base.lib.flatrender" (dict "value" . "context" $context) | nindent 4 }}
  {{- end }}
{{- with $config.data }}
data:
  {{- include "common.tplvalues.render" (dict "value" . "context" $context) | nindent 2 }}
{{- end }}

{{- end -}}
{{- end -}}
