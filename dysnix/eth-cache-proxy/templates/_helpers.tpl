{{/* vim: set filetype=mustache: */}}

{{/*
Fullname (of the default component)
*/}}
{{- define "eth-cache-proxy.fullname" -}}
{{- include "base.fullname" (dict "value" .Values "context" .) -}}
{{- end -}}

{{/*
Return Redis&trade; password
*/}}
{{- define "eth-cache-proxy.redisPassword" -}}
  {{- if .Values.redis.enabled -}}
    {{- include "redis.password" (dict "Values" (merge (dict "global" .Values.global) .Values.redis)) -}}
  {{- else -}}
    {{- .Values.config.redis.password -}}
  {{- end -}}
{{- end -}}

{{- define "eth-cache-proxy.redisWriteHost" -}}
{{- if and .Values.redis.enabled (empty .Values.redis.writeAddrs) -}}
  {{- printf "%s-redis-master:6379" (include "common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $)) }}
{{- else -}}
  {{- printf "%s:%d" (.Values.redis.writeAddrs | default "0.0.0.0") (.Values.redis.port | int | default 6379 ) }}
{{- end }}
{{- end }}

{{- define "eth-cache-proxy.redisReadHost" -}}
{{- if and .Values.redis.enabled (empty .Values.redis.readAddrs) -}}
  {{- printf "%s-redis-master:6379" (include "common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $)) }}
{{- else -}}
  {{- printf "%s:%d" (.Values.redis.readAddrs | default "0.0.0.0") (.Values.redis.port | int | default 6379 ) }}
{{- end }}
{{- end }}

{{- define "eth-cache-proxy.config" -}}
  {{- $redis := eq .Values.cacheType "redis" | ternary (tpl (.Files.Get "default-redis.yaml.gotmpl") .) "{}" | fromYaml -}}
  {{- $olric := eq .Values.cacheType "olric" | ternary (tpl (.Files.Get "default-olric.yaml.gotmpl") .) "{}" | fromYaml -}}
  {{- $common := tpl (.Files.Get "default-common.yaml.gotmpl") . | fromYaml -}}
  {{- get (merge .Values $common $redis $olric) "config" | toYaml  -}}
{{- end -}}
