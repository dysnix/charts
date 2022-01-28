{{- define "rpcfast-gateway.mergeConfigs" -}}
  {{- deepCopy .Values.configs | mergeOverwrite (.Files.Get "default-configs.yml" | fromYaml) | toYaml -}}
{{- end -}}