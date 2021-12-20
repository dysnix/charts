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

{{- with $value.dnsPolicy }}
dnsPolicy: {{ . }}
{{- end }}

{{- with $value.priorityClassName }}
priorityClassName: {{ . }}
{{- end }}

{{- "" }}
serviceAccountName: {{ template "base.serviceAccountName" (dict "serviceAccount" $value.serviceAccount "component" $component "context" $context) }}

{{- with include "base.tpl.render" (dict "value" $value.hostAliases "context" $context) }}
hostAliases: {{- . | nindent 2 }}
{{- end }}

{{- with include "base.tpl.render" (dict "value" $value.affinity "context" $context) }}
{{- if . }}
affinity: {{- . | nindent 2 }}
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
{{- end }}

{{- with include "base.tpl.render" (dict "value" $value.nodeSelector "context" $context) }}
nodeSelector: {{- . | nindent 2 }}
{{- end }}

{{- with include "base.tpl.render" (dict "value" $value.tolerations "context" $context) }}
tolerations: {{- . | nindent 2 }}
{{- end }}

{{- if $value.schedulerName }}
schedulerName: {{ $value.schedulerName | quote -}}
{{- end }}

{{- with include "base.securityContext" (dict "securityContext" $value.podSecurityContext) }}
securityContext: {{ . | nindent 2 }}
{{- end }}

{{- with include "base.tpl.flatlist" (dict "value" (list $value.initContainers) "context" $context) }}
initContainers: {{- . | nindent 2 }}
{{- end }}

{{- "" }}
containers: {{- include "base.containers.podContainers" (dict "value" $value "component" $component "context" $context) | nindent 2 }}

{{- with (include "base.volumes.spec" (dict "value" $value "context" $context)) }}
volumes: {{ . | indent 2 }}
{{- end }}

{{- end -}}
