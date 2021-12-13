{{/* vim: set filetype=mustache: */}}

{{- define "eth-cache-proxy.waitForRedis" -}}
  {{- if .Values.redis.enabled -}}
- name: check-redis-read
  image: alpine:3.9.2
  command:
    - sh
    - -c
    - |
      until printf "." && nc -z -w 2 {{ include "eth-cache-proxy.redisReadHost" . }} 6379; do
          sleep 2;
      done;

      echo 'Redis OK ✓'
- name: check-redis-write
  image: alpine:3.9.2
  command:
    - sh
    - -c
    - |
      until printf "." && nc -z -w 2 {{ include "eth-cache-proxy.redisWriteHost" . }} 6379; do
          sleep 2;
      done;

      echo 'Redis OK ✓'
  {{- end -}}
{{- end -}}