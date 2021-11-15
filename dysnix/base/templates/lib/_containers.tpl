{{/* vim: set filetype=mustache: */}}

{{/*
Kubernetes containers list

Usage:
  {{- include "base.lib.containers" (dict "value" .Values.path.to.dict "context" $) -}}

Params:
  value - value (dict) com
  component - specifies the component name (used for naming and labeling)
  context - template render context
*/}}
{{- define "base.lib.containers" -}}
  {{- $context := .context -}}
  {{- $value := .value -}}
  {{- $component := .component -}}
  {{- $name_list := list -}}

  {{- template "base.lib.validate" (dict "template" "base.validate.context" "context" $context) -}}
  {{- template "base.lib.validate" (dict "template" "base.validate.componentGiven" "component" $component "context" $context) -}}

  {{- if eq "_default" $component -}}
    {{- $name_list = append $name_list $context.Chart.Name -}}
  {{- end -}}
  {{- $name_list = append $name_list $component -}}

- {{- include "base.container" (dict "container" $value "name" ($name_list | first) "context" $context) | nindent 2 }}

  {{- range $container := $value.podContainers }}
-   {{- include "base.container" (dict "container" $container "parent" $value "context" $context) | nindent 2 }}
  {{- end }}

  {{- range $o := default (list) $value.sidecars }}
-
  name: {{ $o.name }}
    {{- include "common.tplvalues.render" (dict "value" (omit $o "name") "context" $context) | nindent 2 }}
  {{- end }}
{{- end -}}
