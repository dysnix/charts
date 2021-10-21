{{/*
This template serves as the blueprint for the PersistentVolumeClaim objects that are created
within the base library.
*/}}
{{- define "base.pvc" }}
{{- if and .Values.persistence.enabled (not .Values.persistence.existingClaim) }}
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: {{ template "common.names.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
spec:
  accessModes:
    - {{ .Values.persistence.accessMode | quote }}
  resources:
    requests:
      storage: {{ .Values.persistence.size | quote }}
  {{ include "base.storageClass" . }}
{{- end -}}
{{- end }}
