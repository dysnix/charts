{{/* vim: set filetype=mustache: */}}

{{/*
Usage:
  {{- include "base.service" (dict "value" .Values.or.path "name" "optional" "component" "optional" "context" $) -}}

Params:
  value - [dict] .Values or path to component values
  context - render context (root is propogated - $)
  name - (optional) specifies the ServiceAccount name supplement
  component - (optional) specifies the component name (used for naming and labeling)
*/}}
{{- define "base.service" -}}

{{- $context := .context -}}
{{- $value := .value -}}
{{- $service := $value | merge dict | dig "service" dict -}}
{{- $component := include "base.component.name" (dict "value" $value "component" .component) -}}
{{- $service_type := $service.type | default "" -}}
{{- $nodePorts := $service.nodePorts | default dict -}}

{{- if or $service.port $service.ports }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "base.fullname" (dict "value" $value "name" .name "component" $component "context" $context) }}
  labels: {{- include "base.labels.standard" (dict "value" $value "component" $component "context" $context) | nindent 4 }}
  {{- with list $service.annotations $context.Values.commonAnnotations | compact }}
  annotations:
    {{- include "base.tpl.flatrender" (dict "value" . "context" $context) | nindent 4 }}
  {{- end }}
spec:
  {{- with $service_type }}
  type: {{ $service_type }}
  {{- end }}
  {{- if or (eq $service_type "LoadBalancer") (eq $service_type "NodePort") }}
  externalTrafficPolicy: {{ $service.externalTrafficPolicy | quote }}
  {{- end }}
  {{- if and (eq $service_type "LoadBalancer") (not (empty $service.loadBalancerSourceRanges)) }}
  loadBalancerSourceRanges: {{ $service.loadBalancerSourceRanges }}
  {{- end }}
  {{- if and (eq $service_type "LoadBalancer") (not (empty $service.loadBalancerIP)) }}
  loadBalancerIP: {{ $service.loadBalancerIP }}
  {{- end }}
  ports:
    {{- if kindIs "map" $service.ports }}
      {{- range $name, $port_or_target := $service.ports }}
    - name: {{ $name }}
      port: {{ include "base.ports.targetPort" (dict "name" $port_or_target "value" $value) }}
      {{- if and (hasKey $nodePorts $name) (or (eq $service_type "NodePort") (eq $service_type "LoadBalancer")) }}
      nodePort: {{ get $nodePorts $name }}
      {{- end }}
      {{- end }}
    {{- else -}}
    {{- include "common.tplvalues.render" (dict "value" $service.ports "context" $context) | nindent 4 }}  
    {{- end }}
    {{- if $service.extraPorts }}
    {{- include "common.tplvalues.render" (dict "value" $service.extraPorts "context" $context) | nindent 4 }}
    {{- end }}
  selector: {{- include "base.labels.matchLabels" (dict "value" $value "component" $component "context" $context) | nindent 4 }}
{{- end -}}

{{- end -}}
