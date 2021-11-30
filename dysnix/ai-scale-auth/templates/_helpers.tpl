{{- define "migration.string" -}}
{{ printf "postgres://%s:%s@%s:%d/%s?sslmode=disable" .Values.postgresql.username .Values.postgresql.password .Values.postgresql.host (.Values.postgresql.port | int) .Values.postgresql.database }}
{{- end }}

{{- define "dafault.postgresql.host" -}}
{{ printf "%s.%s.svc.cluster.local" (include "common.names.fullname" .) .Release.Namespace }}
{{- end }}

{{- define "merge.configs" -}}
{{- $data := pick .Values.postgresql "username" "password" "database" "host" "port" -}}
{{- deepCopy (deepCopy .Values.configs | mergeOverwrite (dict "postgres" $data)) | mergeOverwrite (include "default.service.configs" . | fromYaml) | toYaml -}}
{{- end -}}