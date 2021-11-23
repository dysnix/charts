{{/* vim: set filetype=mustache: */}}

{{/*
Return true if cert-manager required annotations for TLS signed certificates are set in the Ingress annotations
Ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
*/}}
{{- define "base.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") (eq "true" (get . "kubernetes.io/tls-acme" )) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return ingress rule paths list. Allows flexible evaluation, provides context:
  - .Values
  - .defaultService
  - .host
Renders all blocks with the template context available.

Params
  host - hostname
  paths - list of maps containing path configuration
  context - global template context
  ingress - (optional) resource
  defaultService - default service name
*/}}
{{- define "base.ingress.rulePaths" -}}
  {{- $ingress := .ingress | default dict -}}
  {{- $context := $.context | merge (dict "host" .host "defaultService" .defaultService) -}}
  {{- range .paths -}}
    {{- with . | merge dict }}
-
  path: {{ .path }}
      {{- if eq "true" (include "common.ingress.supportsPathType" $.context) }}
  pathType: {{ default "ImplementationSpecific" .pathType }}
      {{- end }}
      {{- if .backend }}
  backend:
    {{- include "common.tplvalues.render" (dict "value" .backend "context" $context) | nindent 4 }}
      {{- else }}
        {{- $service := tpl (list $.defaultService $ingress.serviceName .serviceName | compact | last | default "") $context }}
  backend:
        {{- $port := list $ingress.servicePort .servicePort | compact | last -}}
        {{- include "common.ingress.backend" (dict "serviceName" $service "servicePort" $port "context" $context) | nindent 4 }}
      {{- end }}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Usage:
  {{- include "base.ingress" (dict "value" .Values.or.path "name" "optional" "component" "optional" "context" $) -}}

Params:
  value - [dict] .Values or path to component values
  context - render context (root is propogated - $)
  name - (optional) specifies name suffix
  component - (optional) specifies the component name (used for naming and labeling)
*/}}
{{- define "base.ingress" -}}

{{- $context := .context -}}
{{- $value := .value -}}
{{- $service := $value | merge dict | dig "service" dict -}}
{{- $ingress := $value | merge dict | dig "ingress" dict -}}
{{- $component := include "base.component.name" (dict "value" $value "component" .component) -}}
{{- $fullname := include "base.fullname" (dict "value" $value "name" .name "component" $component "context" $context) -}}

{{/* Validations */}}
{{- template "base.validate" (dict "template" "base.validate.context" "context" $context) -}}

{{- if and $ingress.enabled $service.ports }}
---
apiVersion: {{ include "common.capabilities.ingress.apiVersion" $context }}
kind: Ingress
metadata:
  name: {{ $fullname }}
  labels: {{- include "base.labels.standard" (dict "value" $value "component" $component "context" $context) | nindent 4 }}
  {{- with list $ingress.annotations $context.Values.commonAnnotations | compact }}
  annotations:
    {{- include "base.tpl.flatrender" (dict "value" . "context" $context) | nindent 4 }}
  {{- end }}
spec:
  rules:
    {{- if $ingress.hostname }}
    - host: {{ $ingress.hostname }}
      http:
        paths:
          {{- with concat (list $ingress) ($ingress.paths | default list) ($ingress.extraPaths | default list) }}
            {{- $rule := dict "paths" . "host" $ingress.hostname "defaultService" $fullname "ingress" $ingress "context" $context }}
            {{- include "base.ingress.rulePaths" $rule | indent 10 }}
          {{- end }}
    {{- end }}
    {{- range concat ($ingress.hosts | default list) ($ingress.extraHosts | default list) | compact -}}
    {{- $hostname := .name }}
    - host: {{ $hostname }}
      http:
        paths:
          {{- with concat (list .) (.paths | default list) }}
            {{- $rule := dict "paths" . "host" $hostname "defaultService" $fullname "ingress" $ingress "context" $context }}
            {{- include "base.ingress.rulePaths" $rule | indent 10 }}
          {{- end }}
    {{- end }}
  {{- if or (and $ingress.tls (or (include "base.ingress.certManagerRequest" $ingress.annotations) $ingress.selfSigned)) $ingress.extraTls }}
  tls:
    {{- if and $ingress.tls (or (include "base.ingress.certManagerRequest" $ingress.annotations) $ingress.selfSigned) }}
    - hosts:
        - {{ $ingress.hostname | quote }}
      secretName: {{ printf "%s-tls" $ingress.hostname }}
    {{- end }}
    {{- if $ingress.extraTls }}
    {{- include "common.tplvalues.render" (dict "value" $ingress.extraTls "context" $context) | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end -}}
{{- end -}}
