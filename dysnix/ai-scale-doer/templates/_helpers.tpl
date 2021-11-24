{{- define "get.certs" }}
  {{- $tlsCrt := "" }}
  {{- $tlsKey := "" }}
  {{- $caCrt := "" }}
  {{- if and (.Values.webhook.certs.generate) (.Values.webhook.enabled) -}}
    {{- $ca := genCA "ai-scale-operator-ca" 3650 }}
    {{- $svcName := include "common.names.fullname" . }}
    {{- $cn := printf "%s.%s.svc" $svcName .Release.Namespace }}
    {{- $altName1 := printf "%s.cluster.local" $cn }}
    {{- $altName2 := printf "%s" $cn }}
    {{- $server := genSignedCert $cn nil (list $altName1 $altName2) 365 $ca }}
    {{- $tlsCrt = b64enc $server.Cert }}
    {{- $tlsKey = b64enc $server.Key }}
    {{- $caCrt =  b64enc $ca.Cert }}
  {{- else if .Values.webhook.enabled }}
    {{- $tlsCrt = required "Required when certs.generate is false" .Values.webhook.certs.server.tls.crt }}
    {{- $tlsKey = required "Required when certs.generate is false" .Values.webhook.certs.server.tls.key }}
    {{- $caCrt = required "Required when certs.generate is false" .Values.webhook.certs.ca.crt }}
  {{- end }}
    {{- $result := dict "tlsCrt" $tlsCrt "tlsKey" $tlsKey "caCrt" $caCrt }}
    {{- $result | toJson }}
{{- end }}

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
    {{- $webhooks = append $webhooks "--enable-webhooks=true" -}}
    {{- if (.Values.webhook.tls).certDir -}}
      {{- $webhooks = append $webhooks (printf "--tls-cert-dir=%s" (.Values.webhook.tls.certDir | default "/etc/webhook/certs")) -}}
    {{- end}}
    {{- $webhooksSrvPort := include "get.webhooks.port" . -}}
    {{- if not (empty $webhooksSrvPort) -}}
      {{- $webhooks = append $webhooks (printf "--webhooks-port=%d" ($webhooksSrvPort | int)) -}}
    {{- end }}
  {{- else }}
      {{- $webhooks = append $webhooks "--enable-webhooks=false" -}}
  {{- end }}
{{- print ($webhooks | toYaml) -}}
{{- end }}

{{/*{{- define "args.webhooks.1" -}}*/}}
{{/*  {{- $defaultFlags := list "-conf=/etc/doer/configs/configs.yaml" "--enable-webhooks=false" "--zap-log-level=debug" -}}*/}}
{{/*  {{- $webhooks := concat (.Values.overrideArgs) $defaultFlags | uniq -}}*/}}
{{/*{{- print ($webhooks | toYaml) -}}*/}}
{{/*{{- end }}*/}}

{{- define "default.volumes" -}}
- name: configs
  configMap:
    name: {{ include "common.names.fullname" . | quote }}
{{- if .Values.webhook.enabled }}
- name: serving-cert
  secret:
    secretName: {{ .Values.webhook.certs.secretName | quote }}
{{- end }}
{{- end }}

{{- define "default.volumeMounts" -}}
- name: configs
  mountPath: /etc/doer/configs
  readOnly: true
{{- if .Values.webhook.enabled }}
- mountPath: {{ (.Values.webhook.tls).certDir | default "/etc/webhook/certs" }}
  name: serving-cert
  readOnly: true
{{- end }}
{{- end }}

{{- define "get.service.ports" -}}
  {{- $mergePorts := .Values.service.overridePorts -}}
  {{- range .Values.containerPorts -}}
    {{- $mergePorts = append $mergePorts (dict "name" .name "protocol" .protocol "port" .containerPort "targetPort" .name) }}
    {{- if contains "https" .name }}
    {{- $mergePorts = append $mergePorts (dict "name" "webhooks" "protocol" .protocol "port" 443 "targetPort" .name) }}
    {{- end }}
  {{- end }}
  {{- $mergePorts | uniq | toYaml -}}
{{- end }}