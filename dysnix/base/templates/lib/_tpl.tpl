{{/* vim: set filetype=mustache: */}}

{{/*
Renders a value or list of values that contains template.
Note: when value is a slice, content is flattened and written line by line

Usage:
{{ include "common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "base.tpl.flatrender" -}}
  {{- if typeIs "string" .value -}}
    {{- tpl .value .context }}
  {{- else if kindIs "slice" .value -}}
    {{- range .value -}}
      {{- if . -}}
        {{- with (include "common.tplvalues.render" (dict "value" . "context" $.context)) -}}
          {{- "" }}{{- . }}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- else -}}
    {{- include "common.tplvalues.render" (dict "value" .value "context" .context) }}
  {{- end -}}
{{- end -}}
