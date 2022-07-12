{{/* vim: set filetype=mustache: */}}
{{/*
Generate standard label set for a resource.

Usage:
  {{- include "base.labels.standard" (dict "value" .value "component" .component "labels" (dict "foo" "bar") "context" $) }}

Params:
  context - root object containing .Values
  value - (optional) dict containing the component values
  component - (optional) component name to add as the label
  lables - (optional) dict with additional labels
*/}}
{{- define "base.labels.standard" -}}
  {{- $context := .context -}}
  {{- $component := include "base.component.name" (dict "value" .value "component" .component) -}}

  {{/* Validations */}}
  {{- template "base.validate" (dict "template" "base.validate.context" "context" $context) -}}

  {{/* skip empty or default component */}}
  {{- if not (has $component (list "" "_default")) -}}
    {{- printf "app.kubernetes.io/component: %s\n" $component -}}
  {{- end -}}

  {{/* add common standard labels */}}
  {{- with (include "common.labels.standard" $context) -}}
    {{- "" }}{{ . }}
  {{- end -}}

  {{- with .labels -}}
    {{- . | toYaml | nindent 0 }}
  {{- end -}}

  {{- with $context.Values.commonLabels -}}
    {{- . | toYaml | nindent 0 }}
  {{- end -}}
{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
*/}}
{{- define "base.labels.matchLabels" -}}
  {{- $context := .context -}}
  {{- $value := .value -}}
  {{- $component := include "base.component.name" (dict "value" $value "component" .component) -}}
  {{- template "base.validate" (dict "template" "base.validate.context" "context" $context) -}}

{{- if not (has $component (list "" "_default")) -}}
  {{- printf "app.kubernetes.io/component: %s\n" .component }}
{{- end -}}

app.kubernetes.io/name: {{ include "common.names.name" $context }}
app.kubernetes.io/instance: {{ $context.Release.Name }}
{{- if $value.matchLabels -}}
{{- with include "base.tpl.render" (dict "value" $value.matchLabels "context" $context) }}
  {{- . | nindent 0 }}
{{- end }}
{{- end -}}

{{- end -}}
