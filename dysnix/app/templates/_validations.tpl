{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "app.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "app.validateValues.ingress-service-port-given" .) -}}
{{- $messages := append $messages (include "app.validateValues.ingress-certmanager-with-secret" .) -}}
{{- $messages := append $messages (include "app.validateValues.service-monitor-ports" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/* Validate that .ingress.servicePort is given */}}
{{- define "app.validateValues.ingress-service-port-given" -}}
{{- if and .Values.ingress.enabled (not (include "app.ingress.service-port" .)) -}}
app: ingress-service-port-given
    Ingress requires service port to direct traffic to. service.ports is
    expected to have a single port set. Otherwise please specify ingress.servicePort.
{{- end -}}
{{- end -}}

{{/* Validate that both ingress selfSigned secret and cert-manager are not used at the same time*/}}
{{- define "app.validateValues.ingress-certmanager-with-secret" -}}
{{- $certmanager := eq (include "common.ingress.certManagerRequest" (dict "annotations" .Values.ingress.annotations)) "true" -}}
{{- if and $certmanager .Values.ingress.tls .Values.ingress.selfSigned -}}
app: ingress-certmanager-with-secret
    Use of certmanager and self-signed TLS secret simultaneously is not allowed.
    Please use either ingress.selfSigned or cert-manager annotations.
{{- end -}}
{{- end -}}

{{/* Validate that both port and targetPort are not set at the same time*/}}
{{- define "app.validateValues.service-monitor-ports" -}}
{{- if and .Values.metrics.enabled .Values.metrics.serviceMonitor.enabled .Values.metrics.serviceMonitor.port .Values.metrics.serviceMonitor.targetPort -}}
app: service-monitor-ports
    Use of metrics.serviceMonitor.port metrics.serviceMonitor.targetPort
    simultaneously is not allowed. Please use either either of them.
{{- end -}}
{{- end -}}