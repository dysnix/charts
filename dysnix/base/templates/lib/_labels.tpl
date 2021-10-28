{{/* vim: set filetype=mustache: */}}
{{/*
Generate standard label set for a resource.

Usage:
  {{- include "base.labels.standard" (dict "value" .value "component" .component "labels" (dict "foo" "bar") "context" $) }}

Params:
  value - dict containing the component values
  context - root object containing .Values
  component - (optional) component name to add as the label
  lables - (optional) dict with additional labels
*/}}
{{- define "base.labels.standard" -}}
  {{- $context := .context -}}
  {{- $value := .value -}}
  {{- $component := include "base.lib.component" (dict "value" $value "component" .component) -}}

  {{/* Validations */}}
  {{- template "base.lib.validate" (dict "template" "base.validate.context" "context" $context) -}}

  {{- if and (not (empty .component)) (ne "_default" .component) }}
    {{- printf "app.kubernetes.io/component: %s\n" .component }}
  {{- end }}
  {{- include "common.labels.standard" $context }}

  {{- with .labels -}}
    {{- . | toYaml | nindent 0 }}
  {{- end -}}
  {{- with $context.Values.commonLabels }}
    {{- . | toYaml | nindent 0 }}
  {{- end }}

{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
*/}}
{{- define "base.labels.matchLabels" -}}
  {{- $context := .context -}}
  {{- $value := .value -}}
  {{- $component := include "base.lib.component" (dict "value" $value "component" .component) -}}
  {{- template "base.lib.validate" (dict "template" "base.validate.context" "context" $context) -}}

{{- if and (not (empty .component)) (ne "_default" .component) -}}
  {{- printf "app.kubernetes.io/component: %s\n" .component }}
{{- end -}}
app.kubernetes.io/name: {{ include "common.names.name" $context }}
app.kubernetes.io/instance: {{ $context.Release.Name }}
{{- end -}}
