{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "proxysql.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "proxysql.fullname" -}}
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
{{- define "proxysql.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "proxysql.labels" -}}
app: {{ include "proxysql.name" . }}
release: {{ .Release.Name }}
helm.sh/chart: {{ include "proxysql.chart" . }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "proxysql.selectorLabels" -}}
app: {{ include "proxysql.name" . }}
release: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "proxysql.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "proxysql.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the proper ProxySQL image name
*/}}
{{- define "proxysql.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | toString -}}
  {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{/*
Return the proper Cluster Job image name
*/}}
{{- define "proxysql.proxysql_cluster.job.image" -}}
{{- $registryName := .Values.proxysql_cluster.job.image.registry -}}
{{- $repositoryName := .Values.proxysql_cluster.job.image.repository -}}
{{- $tag := .Values.proxysql_cluster.job.image.tag | toString -}}
  {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{/*
ProxySQL SSL directory
*/}}
{{- define "proxysql.sslDir" -}}
{{- if .Values.ssl.fromSecret -}}
/etc/proxysql/ssl
{{- else -}}
{{ .Values.ssl.sslDir }}
{{- end -}}
{{- end -}}
