{{/* vim: set filetype=mustache: */}}

{{/*
Generates Kubernetes Deployment

Usage:
  {{- include "base.deployment" (dict "value" .Values.path.deployment " "component" "foo" "context" $) }}

Params:
  value - deployment (dict)
  context - template render context
  component - component name used for naming and labeling

Note:
  - value.component has precedence over .component. For the default pod
      "_default" passed as .component parameter.
  - value is expected to be .Values/.Values.mycomponentfoo etc.
*/}}
{{- define "base.deployment" -}}
{{- $value := .value -}}
{{- $context := .context -}}
{{- $component := include "base.lib.component" (dict "value" $value "component" .component) -}}

{{/* Validations */}}
{{- template "base.lib.validate" (dict "template" "base.validate.context" "context" $context) -}}
{{- template "base.lib.validate" (dict "template" "base.validate.componentGiven" "component" $component "context" $context) }}
---
apiVersion: {{ include "common.capabilities.deployment.apiVersion" $context }}
kind: Deployment
metadata:
  name: {{ include "base.lib.fullname" (dict "value" $value "name" $component "context" $context) }}
  labels: {{- include "base.labels.standard" (dict "value" $value "component" $component "context" $context) | nindent 4 }}
  {{- if $context.Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" $context.Values.commonAnnotations "context" $context) | nindent 4 }}
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
      {{- if or $value.checksums $value.podAnnotations }}
      annotations:
        {{- range $value.checksums }}
        checksum/{{ . | trimPrefix "/" }}: {{ include (print $context.Template.BasePath "/" (. | trimPrefix "/")) $context | sha256sum }}
        {{- end }}
        {{- if $value.podAnnotations }}
        {{- include "common.tplvalues.render" (dict "value" $value.podAnnotations "context" $context) | nindent 8 }}
        {{- end }}
      {{- end }}
      labels:
        {{- include "base.labels.standard" (dict "value" $value "component" $component "context" $context) | nindent 8 }}
        {{- if $value.podLabels }}
          {{- include "common.tplvalues.render" (dict "value" $value.podLabels "context" $context) | nindent 8 }}
        {{- end }}
    spec:
      {{- include "base.pod.spec" (dict "value" $value "component" $component "context" $context) | nindent 6 -}}
{{- end -}}
