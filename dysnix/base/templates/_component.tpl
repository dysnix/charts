{{/* vim: set filetype=mustache: */}}
{{/*
Render all resources
Usage:
  {{ include "base.all" $) }}
*/}}
{{- define "base.all" -}}
  {{- include "base.component" (dict "component" "_default" "value" $.Values "context" $) -}}
{{- end -}}

{{/*
Usage:
  {{ include "base.component" (dict "value" .Values.path.to.component "context" $) }}

Params:
  value - dict with component values
  context - render context (root is propogated - $)
  component - (optional) specifies the component name (used for naming and labeling)
*/}}
{{- define "base.component" -}}
  {{- $value := .value -}}
  {{- $context := .context -}}
  {{- $component := include "base.lib.component" (dict "value" $value "component" .component) -}}
  {{- $pod := pick $value "enabled" "controller" -}}

  {{/* Validations */}}
  {{- template "base.lib.validate" (dict "template" "base.validate.context" "context" $context) -}}

  {{- if eq .component "_default" -}}
    {{ $pod = mergeOverwrite $pod ($value.defaultPod | merge dict) }}
  {{- end -}}

  {{- if $pod.enabled -}}
    {{/* Pod controller (ex deployment/statefulset etc) */}}
    {{- template "base.lib.validate" (dict "template" "base.validate.controllerSupported" "controller" $pod.controller "context" $context) -}}
    {{- include (printf "base.%s" $pod.controller) (dict "value" $value "component" $component "context" $context) -}}

    {{/* PersistentVolumeClaim (for Deployment resource) */}}
    {{- if eq $pod.controller "deployment" -}}
      {{- include "base.pvc" (dict "value" $value "component" $component "context" $context) -}}
    {{- end -}}

    {{/* ServiceAccount generation */}}
    {{- include "base.serviceAccount" (dict "value" $value "component" $component "context" $context) -}}

    {{/* ConfigMap generation */}}
    {{- include "base.configMap" (dict "value" $value "component" $component "context" $context) -}}

    {{/* Secret generation */}}
    {{- include "base.secret" (dict "value" $value "component" $component "context" $context) -}}
  {{- end -}}
{{- end -}}
