{{/* vim: set filetype=mustache: */}}

{{/*
Container ports section
ref: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#containerport-v1-core

Usage:
  {{ include "base.lib.containerPorts" (dict "ports" .Values.containerPorts "context" $) }}

Params:
  ports - container ports object, dict or list
  context - template render context

Ports can have a dict form, e.g.
  http: 80
  https: 443
in this case all port numbers refer to the default protocol which is TCP.

Note: for finegrained controll use the list form (for e.g to specify protocol or targetPort)
*/}}
{{- define "base.lib.containerPorts" -}}
{{- if and .ports (kindIs "map" .ports) -}}
ports:
    {{- range $name, $port := .ports }}
  - name: {{ $name }}
    containerPort: {{ $port | int }}
    {{- end }}
{{- else if .ports -}}
ports:
    {{- range $item := .ports }}
  - name: {{ $item.name }}
      {{- include "common.tplvalues.render" (dict "value" (omit $item "name") "context" $.context) | nindent 4 }}
    {{- end }}
{{- end -}}
{{- end -}}

{{/*
Container volumeMounts section

Usage
  {{- include "base.lib.volumeMounts" (dict "value" $value "context" $context) | nindent 2 }}
*/}}
{{- define "base.lib.volumeMounts" -}}
  {{- $context := .context -}}
  {{- $value := .value -}}
  {{- $persistence := .value | merge dict | dig "persistence" dict -}}
  {{- template "base.lib.validate" (dict "template" "base.validate.context" "context" $context) -}}

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
Kubernetes containers list

Usage:
  {{- include "base.lib.containers" (dict "value" .Values.path.to.dict "context" $) -}}

Params:
  value - value (dict) com
  component - specifies the component name (used for naming and labeling)
  context - template render context
*/}}
{{- define "base.lib.containers" -}}
  {{- $context := .context -}}
  {{- $value := .value -}}
  {{- $component := .component -}}
  {{- $name_list := list -}}

  {{- template "base.lib.validate" (dict "template" "base.validate.context" "context" $context) -}}
  {{- template "base.lib.validate" (dict "template" "base.validate.componentGiven" "component" $component "context" $context) -}}

  {{- if eq "_default" $component -}}
    {{- $name_list = append $name_list $context.Chart.Name -}}
  {{- end -}}
  {{- $name_list = append $name_list $component -}}

- {{- include "base.container" (dict "container" $value "name" ($name_list | first) "context" $context) | nindent 2 }}

  {{- range $container := $value.podContainers }}
-   {{- include "base.container" (dict "container" $container "parent" $value "context" $context) | nindent 2 }}
  {{- end }}

  {{- range $o := default (list) $value.sidecars }}
-
  name: {{ $o.name }}
    {{- include "common.tplvalues.render" (dict "value" (omit $o "name") "context" $context) | nindent 2 }}
  {{- end }}
{{- end -}}
