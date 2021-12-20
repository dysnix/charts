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
{{- $component := include "base.component.name" (dict "value" $value "component" .component) -}}

{{/* Validations */}}
{{- template "base.validate" (dict "template" "base.validate.context" "context" $context) -}}

{{- if and (eq "true" (get $config "create" | toString | default "true")) ($config.data | default false) }}
---
apiVersion: v1
kind: ConfigMap
{{- if (semverCompare ">=1.18-0" (include "common.capabilities.kubeVersion" $context)) }}
immutable: {{ $config.immutable }}
{{- end }}
metadata:
  name: {{ include "base.fullname" (dict "value" $value "name" .name "component" $component "context" $context) }}
  labels: {{- include "base.labels.standard" (dict "value" $value "component" $component "context" $context) | nindent 4 }}
  {{- with include "base.tpl.flatmap" (dict "value" (list $config.annotations $context.Values.commonAnnotations) "context" $context) }}
  annotations: {{- . | nindent 4 }}
  {{- end }}
{{- with $config.data }}
data:
  {{- include "common.tplvalues.render" (dict "value" . "context" $context) | nindent 2 }}
{{- end }}
{{- end -}}
{{- end -}}
