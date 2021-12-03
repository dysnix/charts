{{- define "eth-cache-proxy.redisWriteHost" -}}
{{ printf "%s-redis-master.%s.svc.cluster.local:6379" .Release.Name .Release.Namespace }}
{{- end }}

{{- define "eth-cache-proxy.redisReadHost" -}}
{{ printf "%s-redis-replicas.%s.svc.cluster.local:6379" .Release.Name .Release.Namespace }}
{{- end }}

{{- define "eth-cache-proxy.mergeConfigs" -}}
{{- $data := pick .Values.redis "username" "password" "database" -}}
{{- $data = deepCopy $data | mergeOverwrite (dict "writeAddrs" (.Values.redis.writeAddrs | default (include "eth-cache-proxy.redisWriteHost" .))) }}
{{- $data = deepCopy $data | mergeOverwrite (dict "readAddrs" (.Values.redis.readAddrs | default (include "eth-cache-proxy.redisReadHost" .))) }}
{{- deepCopy (deepCopy .Values.configs | mergeOverwrite (dict "redis" $data)) | mergeOverwrite (.Files.Get "default-configs.yml" | fromYaml) | toYaml -}}
{{- end -}}