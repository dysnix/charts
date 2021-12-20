{{/* vim: set filetype=mustache: */}}

{{/*
Renders and performs flattening

Usage:
  {{ include "base.tpl.flatrender" ( dict "value" .Values.path.to.the.Value "context" $) }}

Params
  .value - a list of objects
  .context - render context
  .type - map or list
*/}}
{{- define "base.tpl.flatrender" -}}
  {{- $result := list -}}
  {{- $type := .type | default "" -}}
  {{- if and (ne $type "list") (ne $type "map")  -}}
    {{- "\n==> base.tpl.flatrender\n    .type is expected, provide list or map!" | fail -}}
  {{- end -}}
  {{- $prefix := eq $type "list" | ternary "- " "" -}}

  {{- range .value }}
    {{- if kindIs "slice" . }}
      {{- range . }}
        {{- with include "base.tpl.render" (dict "value" . "context" $.context) }}
          {{- $result = append $result (printf "%s%s" $prefix (. | nindent 2 | trimPrefix "\n  ")) }}
        {{- end }}
      {{- end }}

    {{- else }}

      {{- with include "base.tpl.render" (dict "value" . "context" $.context) }}
        {{- if ne "null" . -}}
          {{- $result = append $result . }}
        {{- end }}
      {{- end }}

    {{- end }}
  {{- end }}

  {{- with $result }}
    {{- $result | join "\n" }}
  {{- end }}
{{- end -}}

{{- define "base.tpl.render" -}}
  {{- with (include "common.tplvalues.render" (dict "value" .value "context" .context)) -}}
    {{- if not (or (eq . "{}") (eq . "[]")) }}
      {{- . }}
    {{- end }}
  {{- end }}
{{- end -}}

{{- define "base.tpl.flatlist" -}}
  {{- include "base.tpl.flatrender" (dict "type" "list" "value" .value "context" .context) }}
{{- end -}}

{{- define "base.tpl.flatmap" -}}
  {{- include "base.tpl.flatrender" (dict "type" "map" "value" .value "context" .context) }}
{{- end -}}
