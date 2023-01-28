{{/* vim: set filetype=mustache: */}}

{{/*
  Returns the chart operation mode direct or library
*/}}
{{- define "app.chart.mode" -}}
  {{- ternary "direct" "library" (eq .Chart.Name "app") -}}
{{- end -}}

{{/*
  Returns proper chart name based on the operation mode
*/}}
{{- define "app.chart.name" -}}
  {{- ternary ._include.topValues.app.name .Chart.Name (eq "direct" (include "app.chart.mode" .)) -}}
{{- end -}}

{{/*
  Component label
*/}}
{{- define "app.labels.component" -}}
  {{- if ._include.component -}}
    app.kubernetes.io/component: {{ ._include.component }}
  {{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "app.serviceAccountName" -}}
  {{- $sa := .Values.serviceAccount | default dict -}}
  {{- if  $sa.create -}}
    {{- default (include "common.names.fullname" .) $sa.name -}}
  {{- else if and ._include.topValues.serviceAccount.create $sa.reuse -}}
    {{- default (include "common.names.fullname" .) ._include.topValues.serviceAccount.name -}}
  {{- else -}}
    {{- default "default" $sa.name -}}
  {{- end -}}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "app.volumePermissions.image" -}}
  {{- include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) -}}
{{- end -}}

{{/*
Return service ports
*/}}
{{- define "app.service.ports" -}}
  {{- $ports := list -}}
  {{- $yaml := printf "ports:\n%s" (include "app.tplvalues.named-list" (dict "value" .Values.service.ports "valueKey" "port" "context" $)) -}}

  {{- range $_, $val := get ($yaml | fromYaml) "ports" -}}
    {{/* Set unset the targetPort for clusterIP == "None" */}}
    {{- if eq $.Values.service.clusterIP "None" -}}
      {{- $val = unset $val "targetPort" -}}
    {{- end -}}

    {{- $ports = append $ports $val -}}
  {{- end -}}

  {{- if $ports -}}
    {{- $ports | toYaml -}}
  {{- end -}}
{{- end -}}

{{/*
Return service name for ingress
*/}}
{{- define "app.ingress.service-name" -}}
  {{- .Values.ingress.serviceName | default (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Locate the service port for ingress
*/}}
{{- define "app.ingress.service-port" -}}
  {{- if .Values.ingress.servicePort -}}
    {{- .Values.ingress.servicePort -}}
  {{- else if and .Values.service.ports (eq (len (keys .Values.service.ports)) 1) (not .Values.ingress.serviceName) -}}
    {{- keys .Values.service.ports | first -}}
  {{- end -}}
{{- end -}}

{{/*
Return ingress backend (with possible service name and port defaults set)
*/}}
{{- define "app.ingress.backend" -}}
  {{- $backend := .backend | default dict -}}
  {{- $port := get $backend "servicePort" | default (include "app.ingress.service-port" .context) -}}
  {{- $service := get $backend "serviceName" | default (include "app.ingress.service-name" .context) -}}
  {{- include "common.ingress.backend" (dict "serviceName" $service "servicePort" $port "context" .context) -}}
{{- end -}}

{{/*
Return workload template checksums
*/}}
{{- define "app.template.checksums" -}}
  {{- range .Values.templateChecksums | default list }}
checksum/{{ . | trimPrefix "/" }}: {{ include (print $.Template.BasePath "/" (. | trimPrefix "/")) $ | sha256sum }}
  {{- end }}
{{- end -}}

{{/*
Return servicemonitor port or targetPort
*/}}
{{- define "app.service-monitor.port" -}}
{{- if .value.port -}}
port: {{ .value.port }}
{{- else if and .value.targetPort (kindIs "string" .value.targetPort) -}}
targetPort: {{ .value.targetPort }}
{{- else -}}
targetPort: {{ .value.targetPort | int }}
{{- end -}}
{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
*/}}
{{- define "common.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- range $key, $value := ._include.topValues.selector.matchLabels }}
{{ $key }}: {{ ternary $value ($value | toString) (kindIs "string" $value) }}
{{- end }}
{{- end -}}