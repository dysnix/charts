{{- define "merge.configs" -}}
{{- $data := pick .Values.prometheus "url" -}}
{{- deepCopy (deepCopy .Values.configs | mergeOverwrite (dict "metricsSource" (dict "prometheus" $data))) | mergeOverwrite (include "default.service.configs" . | fromYaml) | toYaml -}}
{{- end -}}