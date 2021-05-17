{{/* vim: set filetype=mustache: */}}
{{/*
Renders a value that contains template.
Usage:
{{ include "pullsecrets.render.toJson" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "pullsecrets.render.toJson" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toJson) .context }}
    {{- end }}
{{- end -}}

{{/*
Kubernetes standard labels
*/}}
{{- define "common.labels.standard" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
helm.sh/chart: {{ include "common.names.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
