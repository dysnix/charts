{{- define "migration.string" -}}
{{ printf "postgres://%s:%s@%s:%d/%s?sslmode=disable" .Values.postgresql.username .Values.postgresql.password .Values.postgresql.host (.Values.postgresql.port | int) .Values.postgresql.database }}
{{- end }}

{{- define "merge.configs" -}}
{{- $data := dict }}
{{- if not (empty (.Values.postgresql.username)) }}
{{- $_ := set $data "username" .Values.postgresql.username }}
{{- end }}
{{- if not (empty (.Values.postgresql.password)) }}
{{- $_ := set $data "password" .Values.postgresql.password }}
{{- end }}
{{- if not (empty (.Values.postgresql.database)) }}
{{- $_ := set $data "database" .Values.postgresql.database }}
{{- end }}
{{- if not (empty (.Values.postgresql.host)) }}
{{- $_ := set $data "host" .Values.postgresql.host }}
{{- end }}
{{- if not (empty (.Values.postgresql.port)) }}
{{- $_ := set $data "port" .Values.postgresql.port }}
{{- end }}
{{- deepCopy (deepCopy .Values.configs | mergeOverwrite (dict "postgres" $data)) | mergeOverwrite (.Files.Get "configs/default.yaml" | fromYaml) | toYaml }}
{{- end }}