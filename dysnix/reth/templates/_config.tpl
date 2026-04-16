{{/*
  toml.value — render a single TOML value with correct typing.
  Handles: bool, float64→int, string (quoted), slice (array), nil.
*/}}
{{- define "toml.value" -}}
  {{- if kindIs "bool" . -}}
    {{ . }}
  {{- else if kindIs "float64" . -}}
    {{ int64 . }}
  {{- else if kindIs "string" . -}}
    {{ . | quote }}
  {{- else if kindIs "slice" . -}}
    [{{ range $i, $v := . }}{{ if $i }}, {{ end }}{{ include "toml.value" $v }}{{ end }}]
  {{- else if kindIs "invalid" . -}}
  {{- else -}}
    {{ . }}
  {{- end -}}
{{- end -}}

{{/*
  toml.section — recursively render a TOML section.
  Args: dict with "data" (the map to render), "prefix" (section path, e.g. "stages.headers").

  Scalar keys are emitted as key = value under the [prefix] header.
  Map keys are emitted as sub-sections [prefix.key] via recursion.
*/}}
{{- define "toml.section" -}}
  {{- $data := .data -}}
  {{- $prefix := .prefix -}}

  {{- /* Collect scalar keys first */ -}}
  {{- $hasScalars := false -}}
  {{- range $k, $v := $data -}}
    {{- if not (kindIs "map" $v) -}}
      {{- $hasScalars = true -}}
    {{- end -}}
  {{- end -}}

  {{- if $hasScalars }}

[{{ $prefix }}]
    {{- range $k, $v := $data -}}
      {{- if not (kindIs "map" $v) }}
{{ $k }} = {{ include "toml.value" $v }}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- /* Recurse into map keys */ -}}
  {{- range $k, $v := $data -}}
    {{- if kindIs "map" $v -}}
      {{- include "toml.section" (dict "data" $v "prefix" (printf "%s.%s" $prefix $k)) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  Main entrypoint: render configToml as TOML.
  Top-level keys become [section] headers.
*/}}
{{- with .Values.configToml -}}
  {{- range $section, $data := . -}}
    {{- if kindIs "map" $data -}}
      {{- include "toml.section" (dict "data" $data "prefix" $section) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
