{{- define "migration.string" -}}
{{ printf "postgres://$PG_USERNAME:$PG_PASSWORD@%s:%d/%s?sslmode=disable" .Values.postgresql.host (.Values.postgresql.port | int) .Values.postgresql.database }}
{{- end }}