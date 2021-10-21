{{/*
This template serves as the blueprint for the Secret objects that are created
within the base library.
*/}}
{{- define "base.secret" }}
{{- range $nameSuffix, $values := .Values.secrets }}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "common.names.fullname" $ }}-{{ $nameSuffix }}
  {{- with $values.annotations }}
  annotations:
  {{- include "common.tplvalues.render" (dict "value" . "context" $) | nindent 4 }}
  {{- end }}
  labels:
  {{- include "common.labels.standard" $ | nindent 4 }}
  {{- with $values.labels }}
  {{- include "common.tplvalues.render" (dict "value" . "context" $) | nindent 4 }}
  {{- end }}
type: Opaque
{{- with $values.data }}
data:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $values.stringData }}
stringData: {{- include "common.tplvalues.render" (dict "value" . "context" $) | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
