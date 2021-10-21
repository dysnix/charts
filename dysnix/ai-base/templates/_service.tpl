{{/*
This template serves as the blueprint for the Service objects that are created
within the base library.
*/}}
{{- define "base.service" }}
{{- if or .Values.service.port .Values.service.ports -}}
{{- $service := .Values.service -}}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ template "common.names.fullname" . }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
  {{- if or .Values.service.annotations .Values.commonAnnotations }}
  annotations:
    {{- if .Values.service.annotations }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.service.annotations "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonAnnotations }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonAnnotations "context" $ ) | nindent 4 }}
    {{- end }}
  {{- end }}
spec:
  type: {{ .Values.service.type }}
  {{- if or (eq .Values.service.type "LoadBalancer") (eq .Values.service.type "NodePort") }}
  externalTrafficPolicy: {{ .Values.service.externalTrafficPolicy | quote }}
  {{- end }}
  {{- if and (eq .Values.service.type "LoadBalancer") (not (empty .Values.service.loadBalancerIP)) }}
  loadBalancerIP: {{ .Values.service.loadBalancerIP }}
  {{- end }}
  ports:
    {{- if .Values.service.port }}
    - name: {{ include "base.service.defaultPortName" (pick .Values.service "port" "targetPort") }}
      port: {{ .Values.service.port }}
      {{- if .Values.service.targetPort }}
      targetPort: {{ .Values.service.targetPort }}
      {{- end }}
      {{- if and (or (eq .Values.service.type "NodePort") (eq .Values.service.type "LoadBalancer")) (not (empty .Values.service.nodePort)) }}
      nodePort: {{ .Values.service.nodePort }}
      {{- end }}
    {{- end }}
    {{- range .Values.service.ports }}
    - name: {{ .name }}
      port: {{ .port }}
      {{- if .targetPort }}
      targetPort: {{ .targetPort }}
      {{- end }}
      {{- if and .nodePort (or (eq $service.type "NodePort") (eq $service.type "LoadBalancer")) }}
      nodePort: {{ .nodePort }}
      {{- end }}
    {{- end }}
    {{- if .Values.profiling.enabled }}
    - name: profiling
      protocol: TCP
      port: {{ .Values.profiling.port | default 6060 }}
      targetPort: profiling
    {{- end }}
    {{- if .Values.monitoring.enabled }}
    - name: metrics
      protocol: TCP
      port: {{ .Values.monitoring.port | default 8080 }}
      targetPort: metrics
    {{- end  }}
  selector: {{- include "common.labels.matchLabels" . | nindent 4 }}
    {{- if .Values.commonSelectors }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonSelectors "context" $ ) | nindent 4 }}
    {{- end }}
{{- end -}}
{{- end }}
