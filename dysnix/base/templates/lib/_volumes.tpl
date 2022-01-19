{{/* vim: set filetype=mustache: */}}

{{/*
Container volumeMounts section

Usage
  {{- include "base.volumes.volumeMounts" (dict "value" $value "context" $context) | nindent 2 }}

Params:
  value - value dict containing persistence
  context - render context (root is propogated - $)
*/}}
{{- define "base.volumes.volumeMounts" -}}
  {{- $context := .context -}}
  {{- $value := .value -}}
  {{- $persistence := .value | merge dict | dig "persistence" dict -}}
  {{- template "base.validate" (dict "template" "base.validate.context" "context" $context) -}}

  {{- if $persistence.enabled }}
    {{- $mount := pick $persistence "volumeName" "mountPath" "mountPropagation" "readOnly" "subPath" "subPathExpr" -}}
    {{- with merge (dict "name" $mount.volumeName) (omit $mount "volumeName") }}
      {{- include "common.tplvalues.render" (dict "value" (list .) "context" $context) | nindent 0 }}
    {{- end }}
  {{- end }}

  {{- with $value.volumeMounts }}
    {{- include "common.tplvalues.render" (dict "value" . "context" $context) | nindent 0 }}
  {{- end }}

  {{- with $value.extraVolumeMounts }}
    {{- include "common.tplvalues.render" (dict "value" . "context" $context) | nindent 0 }}
  {{- end }}
{{- end -}}

{{/*
Pod volumes section

Usage
  {{- include "base.volumes.spec" (dict "value" $value "context" $context) | nindent 2 }}

Params:
  value - value dict containing persistence
  context - render context (root is propogated - $)
  name - (optinal) volume name (by default .value.volumeName is used)
  component - (optional) specifies the component name (used for naming and labeling)
*/}}
{{- define "base.volumes.spec" -}}
  {{- $value := .value -}}
  {{- $context := .context -}}
  {{- $persistence := .value | merge dict | dig "persistence" dict -}}
  {{- $ephemeral := $persistence | merge dict | dig "ephemeral" (dict "enabled" false) -}}
  {{- $component := .component | default "" -}}
  {{- $name := .name | default $persistence.volumeName -}}
  {{- template "base.validate" (dict "template" "base.validate.context" "context" $context) -}}

  {{- if $persistence.enabled }}
- name: {{ $name }}
  {{- if and $ephemeral.enabled (eq $ephemeral.type "emptyDir") }}
  emptyDir: {}
  {{- else }}
  persistentVolumeClaim:
    claimName: {{ include "base.fullname" (dict "value" $value "name" $name "component" $component "context" $context) }}
  {{- end }}
  {{- end }}

  {{- with $value.volumes }}
    {{- include "common.tplvalues.render" (dict "value" . "context" $context) | nindent 0 }}
  {{- end }}

  {{- with $value.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" . "context" $context) | nindent 0 }}
  {{- end }}
{{- end -}}
