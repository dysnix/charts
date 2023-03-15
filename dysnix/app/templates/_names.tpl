{{/* vim: set filetype=mustache: */}}
{{/*
  Overrides common template functions to support both library and direct modes.
  Takes component into account.
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "common.names.name" -}}
  {{- default (include "app.chart.name" .) .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.names.fullname" -}}
  {{- $fullname := list -}}
  {{- if .Values.fullnameOverride -}}
    {{- $fullname = append $fullname .Values.fullnameOverride -}}
  {{- else -}}
    {{- $name := default (include "app.chart.name" .) .Values.nameOverride -}}
    {{- if contains $name .Release.Name -}}
      {{- $fullname = append $fullname .Release.Name -}}
    {{- else -}}
      {{- $fullname = append $fullname (printf "%s-%s" .Release.Name $name) -}}
    {{- end -}}
  {{- end -}}
  {{- $fullname = append $fullname ._include.component | compact -}}

  {{- join "-" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Extended common.names.fullname with custom name overrides */}}
{{- define "app.fullname" -}}
{{- if .context -}}
    {{- if .customName -}}
      {{- include "common.tplvalues.render" (dict "value" .customName "context" .context) -}}
    {{- else -}}
      {{- template "common.names.fullname" .context -}}
  {{- end -}}
{{- else -}}
  {{- template "common.names.fullname" . -}}
{{- end -}}
{{- end -}}