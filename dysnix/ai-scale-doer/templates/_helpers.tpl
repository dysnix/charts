{{- define "get.health.port" -}}
  {{- range .Values.containerPorts -}}
    {{- if contains "probes" .name }}
      {{- print .containerPort }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "get.webhooks.port" -}}
  {{- range .Values.containerPorts -}}
    {{- if or (contains "https" .name) (contains "webhook" .name) }}
      {{- print .containerPort }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "get.metrics.port" -}}
  {{- range .Values.containerPorts -}}
    {{- if contains "metric" .name }}
      {{- print .containerPort }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "args.webhooks" -}}
  {{- $defaultFlags := list "--leader-elect=false" "--sync-period=120s" "-conf=/etc/doer/configs/configs.yaml" -}}
  {{- $webhooks := concat (.Values.overrideArgs) $defaultFlags | uniq -}}
  {{- $webhooks = append $webhooks (printf "--health-probe-bind-address=:%d" (include "get.health.port" . | int)) -}}
  {{- $webhooks = append $webhooks (printf "--metrics-bind-address=:%d" (include "get.metrics.port" . | int)) -}}
  {{- if .Values.webhook.enabled -}}
    {{- $webhooks = append $webhooks "--disable-webhooks=true" -}}
    {{- if (.Values.webhook.tls).certDir -}}
      {{- $webhooks = append $webhooks (printf "--tls-cert-dir=%s" (.Values.webhook.tls.certDir | default "/etc/webhook/certs")) -}}
    {{- end}}
    {{- $webhooksSrvPort := include "get.webhooks.port" . -}}
    {{- if not (empty $webhooksSrvPort) -}}
      {{- $webhooks = append $webhooks (printf "--webhooks-port=%d" ($webhooksSrvPort | int)) -}}
    {{- end }}
  {{- else }}
      {{- $webhooks = append $webhooks "--disable-webhooks=false" -}}
  {{- end }}
{{- print ($webhooks | toYaml) -}}
{{- end }}