{{- define "predictkube-auth.migrationString" -}}
{{ printf "postgres://%s:%s@%s:%d/%s?sslmode=disable" .Values.postgresql.username .Values.postgresql.password (.Values.postgresql.host | default (include "predictkube-auth.postgresqlHost" .)) (.Values.postgresql.port | int) .Values.postgresql.database }}
{{- end }}

{{- define "predictkube-auth.postgresqlHost" -}}
{{ printf "%s-postgresql.%s.svc.cluster.local" (include "common.names.fullname" .) .Release.Namespace }}
{{- end }}

{{- define "predictkube-auth.mergeConfigs" -}}
{{- $data := pick .Values.postgresql "username" "password" "database" "port" -}}
{{- $data = deepCopy $data | mergeOverwrite (dict "host" (.Values.postgresql.host | default (include "predictkube-auth.postgresqlHost" .))) }}
{{- deepCopy (deepCopy .Values.configs | mergeOverwrite (dict "postgres" $data)) | mergeOverwrite (.Files.Get "default-configs.yml" | fromYaml) | toYaml -}}
{{- end -}}