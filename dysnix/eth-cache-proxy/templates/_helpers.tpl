{{- define "eth-cache-proxy.redisHost" -}}
{{ printf "%s-redis-master.%s.svc.cluster.local" .Release.Name .Release.Namespace }}
{{- end }}

{{- define "eth-cache-proxy.mergeConfigs" -}}
{{- $data := pick .Values.redis "username" "password" "database" "port" -}}
{{- $data = deepCopy $data | mergeOverwrite (dict "host" (.Values.redis.host | default (include "eth-cache-proxy.redisHost" .))) }}
{{- deepCopy (deepCopy .Values.configs | mergeOverwrite (dict "redis" $data)) | mergeOverwrite (.Files.Get "default-configs.yml" | fromYaml) | toYaml -}}
{{- end -}}