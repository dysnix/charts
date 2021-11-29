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

{{/* imagePullSecrets: */}}
{{- template "common.images.pullSecrets" (dict "images" (list $value.image) "global" $context.Values.global) }}

{{- if $value.dnsPolicy }}
dnsPolicy: {{ $value.dnsPolicy }}
{{- end }}

{{- if $value.priorityClassName }}
priorityClassName: {{ $value.priorityClassName | quote }}
{{- end }}

{{- "" }}
serviceAccountName: {{ template "base.serviceAccountName" (dict "serviceAccount" $value.serviceAccount "component" $component "context" $context) }}

{{- if $value.hostAliases }}
hostAliases: {{- include "common.tplvalues.render" (dict "value" $value.hostAliases "context" $context) | nindent 2 }}
{{- end }}

{{- if $value.affinity }}
affinity: {{- include "common.tplvalues.render" (dict "value" $value.affinity "context" $context) | nindent 2 }}
{{- else }}
  {{- if or $value.podAffinityPreset $value.podAntiAffinityPreset $value.nodeAffinityPreset }}
affinity:
  {{- with $value.podAffinityPreset }}
  podAffinity: {{- include "common.affinities.pods" (dict "type" . "component" $value.component $ "context" $context) | nindent 4 }}
  {{- end }}
  {{- with $value.podAntiAffinityPreset }}
  podAntiAffinity: {{- include "common.affinities.pods" (dict "type" . "component" $value.component "context" $context) | nindent 4 }}
  {{- end }}
  {{- with $value.nodeAffinityPreset -}}
    {{- with (include "common.affinities.nodes" (dict "type" .type "key" .key "values" .values)) -}}
  nodeAffinity: {{- . | nindent 4 }}
    {{- end -}}
  {{- end }}
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

{{- with (include "base.securityContext" (dict "securityContext" $value.podSecurityContext)) }}
securityContext: {{ . | nindent 2 }}
{{- end }}

{{- if $value.initContainers }}
initContainers: {{- include "common.tplvalues.render" (dict "value" $value.initContainers "context" $context) | nindent 2 -}}
{{- end }}

containers: {{- include "base.containers.podContainers" (dict "value" $value "component" $component "context" $context) | nindent 2 }}

{{- with (include "base.volumes.spec" (dict "value" $value "context" $context)) }}
volumes: {{ . | indent 2 }}
{{- end }}

{{- end -}}
