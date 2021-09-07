{{/*
This template serves as the blueprint for the ConfigMap objects that are created
within the base library.
*/}}
{{- define "base.configMap" }}
{{- range $nameSuffix, $values := .Values.configMaps }}
---
apiVersion: v1
kind: ConfigMap
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
{{- with $values.data }}
data:
  {{- include "common.tplvalues.render" (dict "value" . "context" $) | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
