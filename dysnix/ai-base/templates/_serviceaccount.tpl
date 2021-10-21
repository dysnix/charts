
{{/*
This template serves as the blueprint for the ServiceAccount objects that are created
within the base library.
*/}}
{{- define "base.serviceAccount" }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "base.serviceAccountName" . }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
  {{- if .Values.commonLabels }}
  {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
  {{- end }}
  {{- if or .Values.serviceAccount.annotations .Values.commonAnnotations }}
  annotations:
  {{- if .Values.serviceAccount.annotations }}
  {{- toYaml .Values.serviceAccount.annotations | nindent 4 }}
  {{- end }}
  {{- if .Values.commonAnnotations }}
  {{- include "common.tplvalues.render" (dict "value" .Values.commonAnnotations "context" $) | nindent 4 }}
  {{- end }}
  {{- end }}
{{- end -}}
