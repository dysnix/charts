{{/*
This template serves as the blueprint for the HorizontalPodAutoscaler objects that are created
within the base library.
*/}}
{{- define "base.hpa" }}
{{- if and .Values.autoscaling.enabled (eq .Values.controller.type  "deployment") }}
---
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: {{ template "common.names.fullname" . }}
  namespace: {{ .Release.Namespace | quote }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: controller
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.commonLabels "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" .Values.commonAnnotations "context" $ ) | nindent 4 }}
  {{- end }}
spec:
  scaleTargetRef:
    apiVersion: {{ include "common.capabilities.deployment.apiVersion" . }}
    kind: Deployment
    name: {{ template "common.names.fullname" . }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
    {{- if .Values.autoscaling.targetCPU }}
    - type: Resource
      resource:
        name: cpu
        targetAverageUtilization: {{ .Values.autoscaling.targetCPU }}
    {{- end }}
    {{- if .Values.autoscaling.targetMemory }}
    - type: Resource
      resource:
        name: memory
        targetAverageUtilization: {{ .Values.autoscaling.targetMemory }}
    {{- end }}
{{- end }}
{{- end }}
