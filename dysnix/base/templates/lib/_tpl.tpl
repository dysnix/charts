{{/* vim: set filetype=mustache: */}}

{{/*
Renders object or list of objects which can be strings/maps/lists.

Note: in case a list is renerered empty itemes are omittied! This enables
      passing of two lists for example ($value.env $value.extraEnv), but finally
      only one is rendered and the rendered content is not poluted with
      extra empty value (such as "[]").

Usage:
  {{ include "base.tpl.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "base.tpl.render" -}}

  {{- if typeIs "string" .value }}
    {{- tpl .value .context }}
  {{- else if kindIs "slice" .value }}

    {{- range $i, $v := .value | compact }}
      {{- if $v }}

        {{- with (include "common.tplvalues.render" (dict "value" $v "context" $.context)) }}
          {{- eq $i 0 | ternary "" "\n" }}{{ include "common.tplvalues.render" (dict "value" $v "context" $.context) }}
        {{- end }}

      {{- end }}
    {{- end }}

  {{- else }}
    {{- include "common.tplvalues.render" (dict "value" .value "context" .context) }}
  {{- end }}

{{- end -}}
