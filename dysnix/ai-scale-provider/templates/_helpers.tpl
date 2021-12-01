{{- define "ai-provider.mergeConfigs" -}}
{{- $data := pick .Values.prometheus "url" -}}
{{- deepCopy (deepCopy .Values.configs | mergeOverwrite (dict "metricsSource" (dict "prometheus" $data))) | mergeOverwrite (.Files.Get "default-configs.yml" | fromYaml) | toYaml -}}
{{- end -}}