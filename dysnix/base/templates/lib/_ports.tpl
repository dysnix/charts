{{/* vim: set filetype=mustache: */}}

{{/*
Container ports section
ref: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#containerport-v1-core

Usage:
  {{ include "lib.ports.containerPorts" (dict "ports" .Values.containerPorts "context" $) }}

Params:
  ports - container ports object, dict or list
  context - template render context

Ports can have a dict form, e.g.
  http: 80
  https: 443
in this case all port numbers refer to the default protocol which is TCP.

Note: for finegrained controll use the list form (for e.g to specify protocol or targetPort)
*/}}
{{- define "base.ports.containerPorts" -}}
  {{- if and .ports (kindIs "map" .ports) -}}
    {{- range $name, $port := .ports }}
- name: {{ $name }}
  containerPort: {{ $port | int }}
    {{- end }}
  {{- else if .ports -}}
    {{- range .ports }}
- name: {{ .name }}
  {{- include "common.tplvalues.render" (dict "value" (omit . "name") "context" $.context) | nindent 2 }}
    {{- end }}
  {{- end -}}
{{- end -}}

{{/*
Lookup target port value

Params
  name - port name to find in .containerPorts, .podContainers.ports, .sidecar.ports
  value - component value
*/}}
{{- define "base.ports.targetPort" -}}
  {{- $name := .name -}}
  {{- if or (typeIs "float64" .name) (typeIs "int" .name) -}}
    {{- printf "%d" (.name | int) -}}

  {{- else -}}
    {{/* Build up ports dict containing all containers ports */}}
    {{- $ports := (.value.containerPorts | default dict) | deepCopy -}}
    {{- range concat (.value.podContainers | default (list dict)) (.value.sidecars | default (list dict)) -}}
      {{/* No container port name should overlap between containers */}}
      {{- $ports = mustMerge $ports (get . "ports" | default dict) -}}
    {{- end -}}

    {{- $found := pluck $name $ports | first -}}
    {{- if not $found -}}
      {{- template "base.validate" (dict "template" "base.validate.containerPortNotFound" "name" $name) -}}
    {{- end -}}
    {{- $found -}}
  {{- end -}}
{{- end -}}
