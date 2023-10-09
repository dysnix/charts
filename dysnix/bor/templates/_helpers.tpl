{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "bor.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "bor.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "bor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "bor.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "bor.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "bor.labels" -}}
helm.sh/chart: {{ include "bor.chart" . }}
app.kubernetes.io/name: {{ include "bor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "bor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "bor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- with .Values.podLabels }}
{{ toYaml . | indent 0 }}
{{- end }}
{{- end }}

{{/*
Convert Golang slice to Toml arrat
*/}}
{{- define "toml.list" -}}
{{- print "[" }}
{{- range $idx, $element := . }}
  {{- if $idx }}, {{ end }}
  {{- $element | quote }}
{{- end -}}
{{ print "]" -}}
{{- end }}

{{/*
Render Toml properties
*/}}
{{- define "toml.properties" -}}
{{- $root := index . 0 }}
{{- $context := index . 1 }}
{{- range $k, $v := $root }}
	{{- if not (kindIs "map" $v) }}
		{{- if kindIs "string" $v }}
			{{- if contains "{{" $v }} {{- /* render templated values */}}
				{{- $v = tpl $v $context }}
				{{- if not (or (regexMatch "^[0-9]+$" $v) (regexMatch "^(true|false)$" $v)) }}
					{{- $v = quote $v }}
				{{- end }}
			{{- else }}
				{{- $v = quote $v }}
			{{- end }}
		{{- else if or (kindIs "int" $v) (kindIs "float64" $v) }}
			{{- $v = int $v }}
		{{- else if kindIs "slice" $v }}
			{{- $v = include "toml.list" $v }}
		{{- end }}
		{{- if contains "." $k }}
			{{- $k = quote $k }}
		{{- end }}
{{ $k }} = {{ $v }}
	{{- end }}
{{- end }}
{{- end }}

{{/*
Render full Toml config including tables
*/}}
{{- define "toml.config" -}}
{{- $context := index . 0 }}
{{- $root := index . 1 }}
{{- include "toml.properties" (list $root $context) }}				{{- /* top-level table */}}
{{- range $k, $v := $root }}
	{{- if kindIs "map" $v }}      
		{{- if contains "." $k }}
			{{- $k = quote $k }}
		{{- end }}

[{{ $k }}]
		{{- include "toml.properties" (list $v $context) }}				{{- /* 1st-level table */}}
		{{- range $i, $j := $v }}
			{{- if kindIs "map" $j }}
				{{- if contains "." $i }}
					{{- $i = quote $i }}
				{{- end }}
				{{- $i = print $k "." $i }}

[{{ $i }}]
				{{- include "toml.properties" (list $j $context) }}		{{- /* 2nd-level table */}}
			{{- end }}
		{{- end }}
	{{- end }}
{{- end }}
{{- end }}