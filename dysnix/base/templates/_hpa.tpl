{{/* vim: set filetype=mustache: */}}

{{/*
Usage:
  {{- include "base.hpa" (dict "value" .Values.or.path "name" "optional" "component" "optional" "context" $) -}}

Params:
  value - [dict] .Values or path to component values
  context - render context (root is propogated - $)
  name - (optional) specifies the ServiceAccount name supplement
  component - (optional) specifies the component name (used for naming and labeling)
*/}}
{{- define "base.hpa" -}}

{{- $context := .context -}}
{{- $value := .value -}}
{{- $hpa := $value | merge dict | dig "autoscaling" dict -}}
{{- $component := include "base.component.name" (dict "value" $value "component" .component) -}}
{{- $fullname := include "base.fullname" (dict "value" $value "name" .name "component" $component "context" $context) -}}

{{/* Validations */}}
{{- template "base.validate" (dict "template" "base.validate.context" "context" $context) -}}

{{- if eq "true" (get $hpa "enabled" | toString | default "false") }}
{{- $metrics := include "base.tpl.flatlist" (dict "value" (list $hpa.metrics) "context" $context) }}
---
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ $fullname}}
  labels: {{- include "base.labels.standard" (dict "value" $value "component" $component "context" $context) | nindent 4 }}
  {{- with include "base.tpl.flatmap" (dict "value" (list $hpa.annotations $context.Values.commonAnnotations) "context" $context) }}
  annotations: {{- . | nindent 4 }}
  {{- end }}
spec:
  scaleTargetRef:
    apiVersion: {{ include "common.capabilities.deployment.apiVersion" $context }}
    kind: {{ include "base.component.controller" (dict "component" $component "value" $value "context" $context) }}
    name: {{ $fullname }}
  minReplicas: {{ $hpa.minReplicas }}
  maxReplicas: {{ $hpa.maxReplicas }}
  {{- if or $metrics $hpa.targetCPU $hpa.targetMemory }}
  metrics:
    {{- if $hpa.targetCPU }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ $hpa.targetCPU }}
    {{- end }}
    {{- if $hpa.targetMemory }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ $hpa.targetMemory }}
    {{- end }}
    {{- with $metrics }}
      {{- . | nindent 4 }}
    {{- end }}
  {{- end }}

{{- end -}}
{{- end -}}
