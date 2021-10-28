{{/* vim: set filetype=mustache: */}}

{{/*
Usage:
  {{- include "base.pod.spec" (dict "value" .Values.path.to.dict "component" "foo" "context" $) -}}

Params:
  value - value dict
  context - render context (root is propogated - $)
  component - specifies the component name (used for naming and labeling)
*/}}
{{- define "base.pod.spec" -}}
{{- $value := .value -}}
{{- $context := .context -}}
{{- $component := .component -}}

{{/* Validations */}}
{{- template "base.lib.validate" (dict "template" "base.validate.componentGiven" "component" $component "context" $context) -}}

{{/* imagePullSecrets: */}}
{{- template "common.images.pullSecrets" (dict "images" (list $value.image) "global" $context.Values.global) }}

{{- if $value.dnsPolicy }}
dnsPolicy: {{ $value.dnsPolicy }}
{{- end }}

{{- if $value.priorityClassName }}
priorityClassName: {{ $value.priorityClassName | quote }}
{{- end }}

{{- if $value.hostAliases }}
hostAliases: {{- include "common.tplvalues.render" (dict "value" $value.hostAliases "context" $context) | nindent 2 }}
{{- end -}}

{{- if $value.affinity }}
affinity: {{- include "common.tplvalues.render" (dict "value" $value.affinity "context" $context) | nindent 2 }}
{{- else }}
affinity:
  {{- with (include "common.affinities.pods" (dict "type" $value.podAffinityPreset "component" $value.component . "context" $context) | default dict) }}
  podAffinity: {{- . | nindent 4 }}
  {{- end }}
  {{- with (include "common.affinities.pods" (dict "type" $value.podAntiAffinityPreset "component" $value.component "context" $context) | default dict) }}
  podAntiAffinity: {{- . | nindent 4 }}
  {{- end }}
  {{- with (include "common.affinities.nodes" (dict "type" $value.nodeAffinityPreset.type "key" $value.nodeAffinityPreset.key "values" $value.nodeAffinityPreset.values)) | default dict -}}
  nodeAffinity: {{- . | nindent 4 }}
  {{- end }}
{{- end }}

{{- if $value.nodeSelector }}
nodeSelector: {{- include "common.tplvalues.render" (dict "value" $value.nodeSelector "context" $context) | nindent 2 -}}
{{- end }}

{{- if $value.tolerations }}
tolerations: {{- include "common.tplvalues.render" (dict "value" $value.tolerations "context" $context) | nindent 2 -}}
{{- end }}

{{- if $value.schedulerName }}
schedulerName: {{ $value.schedulerName | quote -}}
{{- end }}

{{- with (include "base.lib.securityContext" (dict "securityContext" $value.podSecurityContext)) }}
podSecurityContext: {{ . | nindent 2 }}
{{- end }}

{{- if $value.initContainers }}
initContainers: {{- include "common.tplvalues.render" (dict "value" $value.initContainers "context" $context) | nindent 2 -}}
{{- end }}

containers: {{- include "base.lib.containers" (dict "value" $value "component" $component "context" $context) | nindent 2 }}
{{- end -}}
