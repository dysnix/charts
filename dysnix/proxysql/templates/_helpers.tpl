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
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

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
ProxySQL SSL directory
*/}}
{{- define "proxysql.sslDir" -}}
{{- if .Values.ssl.fromSecret -}}
/etc/proxysql/ssl
{{- else -}}
/etc/proxysql
{{- end -}}
{{- end -}}

{{/*
ProxySQL SSL config
*/}}
{{- define "proxysql.sslConf" -}}
{{- if .Values.ssl.fromSecret }}
ssl_p2s_ca="{{ include "proxysql.sslDir" . }}/ca.pem"
{{- else if .Values.ssl.ca }}
ssl_p2s_ca="{{ include "proxysql.sslDir" . }}/ca.pem"
{{- end -}}
{{- if or (and .Values.ssl.cert .Values.ssl.key) .Values.ssl.fromSecret }}
ssl_p2s_cert="{{ include "proxysql.sslDir" . }}/cert.pem"
ssl_p2s_key="{{ include "proxysql.sslDir" . }}/key.pem"
{{- end -}}
{{- end -}}

{{/*
ProxySQL proxysql.cnf
*/}}
{{- define "proxysql.conf" -}}
{{- $sslEnabled := or (and .Values.ssl.cert .Values.ssl.key) .Values.ssl.fromSecret -}}
datadir="/data/proxysql"

admin_variables=
{
  mysql_ifaces="127.0.0.1:6032"
  {{- range $key, $value := .Values.admin_variables }}
  {{ $key }}={{ $value | toJson }}
  {{- end }}
}

mysql_variables=
{
  interfaces="0.0.0.0:6033"
  {{- include "proxysql.sslConf" . | indent 2 }}
  {{- range $key, $value := .Values.mysql_variables }}
  {{ $key }}={{ $value | toJson }}
  {{- end }}
}

mysql_servers=
(
  {{- range $_, $server := .Values.mysql_servers }}
  {
    {{- if and $sslEnabled (not (hasKey $server "use_ssl")) -}}
    {{- $server := merge $server (dict "use_ssl" 1) }}
    {{- end }}
    {{- range $key, $value := $server }}
    {{ $key }}={{ $value | toJson }}
    {{- end }}
  },
  {{- end }}
)

mysql_users=
(
  {{- range $_, $user := .Values.mysql_users }}
  {
    {{- if hasKey $user "active" -}}
    {{- $server := merge $user (dict "active" 1) }}
    {{- end }}
    {{- range $key, $value := $user }}
    {{ $key }}={{ $value | toJson }}
    {{- end }}
  },
  {{- end }}
)

mysql_query_rules=
(
  {{- range $idx, $rule := .Values.mysql_query_rules }}
  {
    rule_id={{ add $idx 1 }}
    {{- range $key, $value := $rule }}
    {{ $key }}={{ $value | toJson }}
    {{- end }}
  },
  {{- end }}
)
{{- end -}}