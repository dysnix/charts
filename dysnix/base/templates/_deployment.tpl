{{/* vim: set filetype=mustache: */}}

{{/*
Generates Kubernetes Deployment

Usage:
  {{- include "base.deployment" (dict "value" .Values.path.deployment " "component" "foo" "context" $) }}

Params:
  value - deployment (dict)
  context - template render context
  component - (optional) component name (used for naming and labeling)
  name - (optional) deployment name suffix (used for naming and labeling)

Note:
  - value.component has precedence over .component
  - value is expected to be .Values/.Values.mycomponentfoo etc.
*/}}
{{- define "base.deployment" -}}
{{- $value := .value -}}
{{- $context := .context -}}
{{- $component := include "base.component.name" (dict "value" $value "component" .component) -}}
{{- $checksums := dict -}}
{{- range $value.checksums | default list -}}
  {{- $checksums = set $checksums (. | trimPrefix "/" | printf "%s") (include (print $context.Template.BasePath "/" (. | trimPrefix "/")) $context | sha256sum) -}}
{{- end -}}

{{/* Validations */}}
{{- template "base.validate" (dict "template" "base.validate.context" "context" $context) }}
---
apiVersion: {{ include "common.capabilities.deployment.apiVersion" $context }}
kind: Deployment
metadata:
  name: {{ include "base.fullname" (dict "value" $value "name" .name "component" $component "context" $context) }}
  labels: {{- include "base.labels.standard" (dict "value" $value "component" $component "context" $context) | nindent 4 }}
  {{- with include "base.tpl.render" (dict "value" $context.Values.commonAnnotations "context" $context) }}
  annotations: {{- . | nindent 4 }}
  {{- end }}
spec:
  replicas: {{ $value.replicaCount }}
  {{- if $value.updateStrategy }}
  strategy: {{- include "common.tplvalues.render" (dict "value" $value.updateStrategy "context" $context) | nindent 4 }}
  {{- end }}
  selector:
    matchLabels: {{- include "base.labels.matchLabels" (dict "value" $value "component" $component "context" $context) | nindent 6 }}
  template:
    metadata:
      {{- with include "base.tpl.flatmap" (dict "value" (list $checksums $value.podAnnotations) "context" $context) }}
      annotations: {{- . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "base.labels.matchLabels" (dict "value" $value "component" $component "context" $context) | nindent 8 }}
        {{- with $value.podLabels }}
          {{- include "common.tplvalues.render" (dict "value" . "context" $context) | nindent 8 }}
        {{- end }}
    spec:
      {{- ""}}{{ include "base.pod.spec" (dict "value" $value "component" $component "context" $context) | indent 6 -}}
{{- end -}}
