{{/* vim: set filetype=mustache: */}}

{{/*
Usage:
  {{- include "base.pvc.spec" (dict "persistence" .Values.path.to.persistence "context" $) -}}

Params:
  persistence - value dict
  context - render context (root is propogated - $)
*/}}
{{- define "base.pvc.spec" -}}
{{- $persistence := .persistence -}}
{{- $context := .context -}}
accessModes:
  {{- if not (empty $persistence.accessModes) }}
    {{- range $persistence.accessModes }}
  - {{ . | quote }}
    {{- end }}
  {{- else }}
  - {{ $persistence.accessMode | quote }}
  {{- end }}
resources:
  requests:
    storage: {{ $persistence.size | quote }}
{{ include "common.storage.class" (dict "persistence" $persistence "global" $context.Values.global) -}}
{{- end -}}

{{/*
Usage:
  {{- include "base.pvc" (dict "value" .Values.path.to.values "name" "name" "component" "foo" "context" $) -}}

Params:
  value - value dict
  context - render context (root is propogated - $)
  name - (optional) name of the volume (.value.volumeName is used by default)
  component -(optional) specifies the component name (used for naming and labeling)
*/}}
{{- define "base.pvc" -}}
{{- $value := .value -}}
{{- $context := .context -}}
{{- $persistence := .value | merge dict | dig "persistence" dict -}}
{{- $ephemeral := $persistence | merge dict | dig "ephemeral" (dict "enabled" false) -}}
{{- $name := .name | default $persistence.volumeName -}}
{{- $component := include "base.component.name" (dict "value" $value "component" .component) -}}

{{- if and $persistence.enabled (not $persistence.existingClaim) ($ephemeral.enabled | toString | ne "true") }}
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: {{ include "base.fullname" (dict "value" $value "name" $name "component" $component "context" $context) }}
  labels: {{- include "base.labels.standard" (dict "value" $value "component" $component "context" $context) | nindent 4 }}
  {{- with include "base.tpl.render" (dict "value" $context.Values.commonAnnotations "context" $context) }}
  annotations: {{- . | nindent 4 }}
  {{- end }}
spec:
  {{- include "base.pvc.spec" (dict "persistence" $persistence "context" $context) | nindent 2 }}
{{- end }}
{{- end -}}
