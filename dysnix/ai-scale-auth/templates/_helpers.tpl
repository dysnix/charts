{{- define "ai-auth.migrationString" -}}
{{ printf "postgres://%s:%s@%s:%d/%s?sslmode=disable" .Values.postgresql.username .Values.postgresql.password (.Values.postgresql.host | default (include "ai-auth.postgresqlHost" .)) (.Values.postgresql.port | int) .Values.postgresql.database }}
{{- end }}

{{- define "ai-auth.postgresqlHost" -}}
{{ printf "%s-postgresql.%s.svc.cluster.local" (include "common.names.fullname" .) .Release.Namespace }}
{{- end }}

{{- define "ai-auth.mergeConfigs" -}}
{{- $data := pick .Values.postgresql "username" "password" "database" "port" -}}
{{- $data = deepCopy $data | mergeOverwrite (dict "host" (.Values.postgresql.host | default (include "ai-auth.postgresqlHost" .))) }}
{{- deepCopy (deepCopy .Values.configs | mergeOverwrite (dict "postgres" $data)) | mergeOverwrite (include "ai-auth.defaultServiceConfigs" . | fromYaml) | toYaml -}}
{{- end -}}