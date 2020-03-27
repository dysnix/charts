{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "pritunl.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pritunl.fullname" -}}
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
{{- define "pritunl.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "pritunl.labels" -}}
app: {{ include "pritunl.name" . }}
helm.sh/chart: {{ include "pritunl.chart" . }}
release: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "pritunl.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "pritunl.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Pritunl mongodb uri template
*/}}
{{- define "pritunl.mongodbUriTemplate" -}}
{{- if .Values.mongodbUriTemplate -}}
{{ .Values.mongodbUriTemplate }}
{{- else if and .Values.mongodb.mongodbUsername .Values.mongodb.mongodbDatabase -}}
{{- $fullName := include "pritunl.fullname" . -}}
{{- printf "mongodb://%s:$PRITUNL_MONGODB_PASSWORD@%s-mongodb/%s" .Values.mongodb.mongodbUsername $fullName .Values.mongodb.mongodbDatabase -}}
{{- end -}}
{{- end -}}
