{{- define "getCerts" }}
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

{{- define "getConfigPath" }}
{{- $path := "" }}
{{- range $_, $val := .Values.volumeMounts }}
{{- if eq $val.name "configs" }}
{{-  $path = $val.mountPath }}
{{- end }}
{{- end }}
{{- printf $path }}
{{- end }}

{{- define "getMetricsPort" }}
{{- $port := "8091" }}
{{- if eq (.Values.monitoring.enabled | toString) "true" }}
{{- if gt (.Values.monitoring.port | toString | atoi) 0 }}
{{-  $port = .Values.monitoring.port | toString }}
{{- end }}
{{- end }}
{{- printf $port }}
{{- end }}

health-probe-bind-address

{{- define "getProbesAddress" }}
{{- $addr := ":8081" }}
{{- if eq (.Values.readinessProbe.enabled | toString) "true" }}
{{- if gt (.Values.readinessProbe.httpGet.port | toString | atoi) 0 }}
{{-  $addr = printf ":%s" (.Values.readinessProbe.httpGet.port | toString) }}
{{- end }}
{{- end }}
{{- printf $addr }}
{{- end }}

{{- define "getWebhookFlags" -}}
- --leader-elect=false
- --sync-period=120s
- -conf={{ include "getConfigPath" . }}/configs.yaml
- --health-probe-bind-address={{ include "getProbesAddress" . }}
{{- if eq (.Values.monitoring.enabled | toString) "true" }}
- --metrics-bind-address={{ printf ":%s" (include "getMetricsPort" .) }}
{{- end }}
{{- if .Values.webhook.enabled }}
- --disable-webhooks=true
{{- if (.Values.webhook.tls).certDir }}
- --tls-cert-dir={{ .Values.webhook.tls.certDir | default "/etc/webhook/certs" }}
{{- end}}
{{- if .Values.webhook.serverPort }}
- --webhooks-port={{ .Values.webhook.serverPort }}
{{- end }}
{{- else }}
- --disable-webhooks=false
{{- end }}
{{- end }}

{{- define "getVolumes" -}}
- name: configs
  configMap:
    name: {{ include "common.names.fullname" . }}-configs
{{- if .Values.webhook.enabled }}
- name: serving-cert
  secret:
    secretName: {{ .Values.webhook.certs.secretName }}
{{- end }}
{{- end }}