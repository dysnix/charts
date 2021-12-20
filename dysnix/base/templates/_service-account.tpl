{{/* vim: set filetype=mustache: */}}

{{/*
Usage:
  {{- include "base.serviceAccount" (dict "value" .Values.or.path "name" "optional" "component" "optional" "context" $) -}}

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
{{- $component := include "base.component.name" (dict "value" $value "component" .component) -}}

{{/* Validations */}}
{{- template "base.validate" (dict "template" "base.validate.context" "context" $context) -}}

{{- if eq "true" (get $sa "create" | toString) }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "base.serviceAccountName" (dict "serviceAccount" $sa "name" .name "component" $component "context" $context) }}
  labels: {{- include "base.labels.standard" (dict "value" $value "component" $component "context" $context) | nindent 4 }}
  {{- with include "base.tpl.flatmap" (dict "value" (list $sa.annotations $context.Values.commonAnnotations) "context" $context) }}
  annotations: {{- . | nindent 4 }}
  {{- end }}
{{- end -}}
{{- end -}}
