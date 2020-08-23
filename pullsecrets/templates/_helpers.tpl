{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "pullsecrets.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pullsecrets.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pullsecrets.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pullsecrets.labels" -}}
helm.sh/chart: {{ include "pullsecrets.chart" . }}
{{ include "pullsecrets.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pullsecrets.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pullsecrets.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "pullsecrets.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "pullsecrets.validateValues.gcr" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Validate values of pullsecrets either gcr.serviceAccountKey, gcr.existingSecret is necessary
to create for adding the gcr pull secret.
*/}}
{{- define "pullsecrets.validateValues.gcr" -}}
{{- if and .Values.gcr.enabled (not .Values.gcr.serviceAccountKey) (not .Values.gcr.existingSecret) }}
pullsecrets: gcr.serviceAccountKey
    gcr.serviceAccountKey must be provided to create image
    pull secret for google container registry.
{{- end -}}
{{- end -}}

{{- define "pullsecrets.gcr" -}}
{{- if .Values.gcr.enabled }}
{{- $gcr := list -}}
{{- $gcrSAKey := ternary (.Values.gcr.serviceAccountKey | b64dec) .Values.gcr.serviceAccountKey .Values.gcr.keyIsBase64 | trim -}}
    {{- range .Values.gcr.locations -}}
        {{- $auth := dict "username" "_json_key" "password" $gcrSAKey "email" (include "pullsecrets.fullname" $) "auth" (printf "_json_key:%s" $gcrSAKey | b64enc) -}}
        {{- $gcr = append $gcr (printf "%q:%s" . ($auth | toJson)) -}}
    {{- end -}}
{{- $gcr | join ", " }}
{{- end }}
{{- end }}

{{- define "pullsecrets.createSecret" -}}
{{- if or (and .Values.gcr.enabled .Values.gcr.locations) -}}
    {{- true -}}
{{- else -}}
{{- end -}}
{{- end -}}
