{{/*
This template serves as the blueprint for the Ingress objects that are created
within the base library.
*/}}
{{- define "base.ingress" }}
{{- if and .Values.ingress.enabled (or .Values.service.port .Values.service.ports) }}
---
apiVersion: {{ include "common.capabilities.ingress.apiVersion" . }}
kind: Ingress
metadata:
  name: {{ include "common.names.fullname" . }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
  annotations:
    {{- include "base.ingress.annotations" . | nindent 4 }}
    {{- if .Values.ingress.annotations }}
    {{- include "common.tplvalues.render" (dict "value" .Values.ingress.annotations "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonAnnotations }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonAnnotations "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  rules:
    {{- if and .Values.ingress.hostname .Values.service.port }}
    - host: {{ .Values.ingress.hostname }}
      http:
        paths:
          {{- if .Values.ingress.extraPaths }}
          {{- toYaml .Values.ingress.extraPaths | nindent 10 }}
          {{- end }}
          - path: {{ .Values.ingress.path }}
            {{- if eq "true" (include "common.ingress.supportsPathType" .) }}
            pathType: {{ .Values.ingress.pathType }}
            {{- end }}
            {{- $svcPort := include "base.service.defaultPortName" (pick .Values.service "port" "targetPort") }}
            backend: {{- include "common.ingress.backend" (dict "serviceName" (include "common.names.fullname" .) "servicePort" $svcPort "context" .) | nindent 14 }}
    {{- end }}
    {{- range .Values.ingress.extraHosts }}
    - host: {{ .name }}
      http:
        paths:
          - path: {{ default "/" .path }}
            {{- if eq "true" (include "common.ingress.supportsPathType" $) }}
            pathType: {{ default "ImplementationSpecific" .pathType }}
            {{- end }}
            backend: {{- include "common.ingress.backend" (dict "serviceName" .serviceName "servicePort" .servicePort "context" $) | nindent 14 }}
    {{- end }}
  {{- if or .Values.ingress.tls .Values.ingress.extraTls }}
  tls:
    {{- if .Values.ingress.tls }}
    - hosts:
        - {{ .Values.ingress.hostname }}
      secretName: {{ printf "%s-tls" .Values.ingress.hostname }}
    {{- end }}
    {{- if .Values.ingress.extraTls }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.ingress.extraTls "context" $ ) | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
