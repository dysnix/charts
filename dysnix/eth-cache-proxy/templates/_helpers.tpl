{{- define "eth-cache-proxy.redisWriteHost" -}}
{{- if and .Values.redis.enabled (empty .Values.redis.writeAddrs) -}}
{{ printf "%s-redis-master.%s.svc.cluster.local:6379" .Release.Name .Release.Namespace }}
{{- else -}}
{{ printf "%s:%d" (.Values.redis.writeAddrs | default "0.0.0.0") (.Values.redis.port | int | default 6379 ) }}
{{- end }}
{{- end }}

{{- define "eth-cache-proxy.redisReadHost" -}}
{{- if and .Values.redis.enabled (empty .Values.redis.readAddrs) -}}
{{ printf "%s-redis-replicas.%s.svc.cluster.local:6379" .Release.Name .Release.Namespace }}
{{- else -}}
{{ printf "%s:%d" (.Values.redis.readAddrs | default "0.0.0.0") (.Values.redis.port | int | default 6379 ) }}
{{- end }}
{{- end }}

{{- define "eth-cache-proxy.mergeConfigs" -}}
{{- $data := pick .Values.redis "username" "password" "database" -}}
{{- $data = deepCopy $data | mergeOverwrite (dict "writeAddrs" (.Values.redis.writeAddrs | default (include "eth-cache-proxy.redisWriteHost" .))) }}
{{- $data = deepCopy $data | mergeOverwrite (dict "readAddrs" (.Values.redis.readAddrs | default (include "eth-cache-proxy.redisReadHost" .))) }}
{{- deepCopy (deepCopy .Values.configs | mergeOverwrite (dict "redis" $data)) | mergeOverwrite (.Files.Get "default-configs.yml" | fromYaml) | toYaml -}}
{{- end -}}