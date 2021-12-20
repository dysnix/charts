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
{{- $component := include "base.component.name" (dict "value" $value "component" .component) -}}

{{/* Validations */}}
{{- template "base.validate" (dict "template" "base.validate.context" "context" $context) -}}

{{- if and (eq "true" (get $secret "create" | toString | default "true")) (or $secret.data $secret.stringData) }}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "base.fullname" (dict "value" $value "name" .name "component" $component "context" $context) }}
  labels: {{- include "base.labels.standard" (dict "value" $value "component" $component "context" $context) | nindent 4 }}
  {{- with include "base.tpl.flatmap" (dict "value" (list $secret.annotations $context.Values.commonAnnotations) "context" $context) }}
  annotations: {{- . | nindent 4 }}
  {{- end }}
type: {{ $secret.type | default "Opaque" }}
{{- with $secret.data }}
data:
  {{- range $k, $v := . }}
  {{ $k }}: {{ include "common.tplvalues.render" (dict "value" $v "context" $context) | trim }}
  {{- end }}
{{- end }}
{{- with $secret.stringData }}
stringData:
  {{- include "common.tplvalues.render" (dict "value" . "context" $context) | nindent 2 }}
{{- end }}
{{- end -}}
{{- end -}}
