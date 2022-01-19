{{/* vim: set filetype=mustache: */}}
{{/*
Render the default component resources
Usage:
  {{ include "base.component.default" $) }}
*/}}
{{- define "base.component.default" -}}
  {{- include "base.component" (dict "component" "_default" "value" $.Values "context" $) -}}
{{- end -}}

{{/*
Outputs the given component controller name

Usage:
  {{ include "base.component.controller" (dict "value" "component" "myComponent" .Values.path.to.component "context" $) }}

Params:
  value - dict with component values
  context - render context (root is propogated - $)
  component - (optional) specifies the component name (used for naming and labeling)
*/}}
{{- define "base.component.controller" -}}
  {{- $value := .value -}}
  {{- $context := .context -}}
  {{- $component := include "base.component.name" (dict "value" $value "component" .component) -}}
  {{- $pod := pick $value "enabled" "controller" -}}

  {{/* Validations */}}
  {{- template "base.validate" (dict "template" "base.validate.context" "context" $context) -}}

  {{- if eq $component "_default" -}}
    {{ $pod = mergeOverwrite $pod ($value.defaultComponent | merge dict) }}
  {{- end -}}

  {{- if eq "true" (get $pod "enabled" | toString | default "true") -}}
    {{- if get $pod "controller" -}}
      {{- template "base.validate" (dict "template" "base.validate.controllerSupported" "controller" $pod.controller "context" $context) -}}
      {{- get $pod "controller" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Get component name!
.value.component has precedence over .component.

Usage:
  {{ include "base.component.name" (dict "value" .path.to.dict "component" .component }}

Params:
  value - (optional) values dict
  component - (optional)
*/}}
{{- define "base.component.name" -}}
  {{- $value := default (dict) .value -}}
  {{- $value.component | default .component | default "" -}}
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
  {{- $component := include "base.component.name" (dict "value" $value "component" .component) -}}
  {{- $pod := pick $value "enabled" "controller" -}}

  {{/* Validations */}}
  {{- template "base.validate" (dict "template" "base.validate.context" "context" $context) -}}

  {{- if eq $component "_default" -}}
    {{ $pod = mergeOverwrite $pod ($value.defaultComponent | merge dict) }}
  {{- end -}}

  {{- if eq "true" (get $pod "enabled" | toString | default "true") -}}
    {{/* Pod controller (ex deployment/statefulset etc) */}}
    {{- if get $pod "controller" -}}
      {{- template "base.validate" (dict "template" "base.validate.controllerSupported" "controller" $pod.controller "context" $context) -}}
      {{- include (printf "base.%s" $pod.controller | lower) (dict "value" $value "component" $component "context" $context) -}}
    {{- end -}}

    {{/* PersistentVolumeClaim for the default Deployment */}}
    {{- if eq (get $pod "controller") "Deployment" -}}
      {{- include "base.pvc" (dict "value" $value "component" $component "context" $context) -}}
    {{- end -}}

    {{/* ServiceAccount generation */}}
    {{- include "base.serviceAccount" (dict "value" $value "component" $component "context" $context) -}}

    {{/* ConfigMap generation */}}
    {{- include "base.configMap" (dict "value" $value "component" $component "context" $context) -}}

    {{/* Secret generation */}}
    {{- include "base.secret" (dict "value" $value "component" $component "context" $context) -}}

    {{/* Service generation */}}
    {{- include "base.service" (dict "value" $value "component" $component "context" $context) -}}

    {{/* ingress generation */}}
    {{- include "base.ingress" (dict "value" $value "component" $component "context" $context) -}}

    {{/* ingress generation */}}
    {{- include "base.hpa" (dict "value" $value "component" $component "context" $context) -}}
  {{- end -}}
{{- end -}}
