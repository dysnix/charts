{{/* vim: set filetype=mustache: */}}

{{/*
Usage:
  {{- include "base.container" (dict "container" .Values.path.to.dict "context" $) -}}

Params:
  name - container name
  container - value (dict) of the container (can be .Values/.Values.component or .podContainers ietms)
  parent - parent value (dict) (whem available represents .Values or component values eg: .Values.mycomponent)
  context - template render context
*/}}
{{- define "base.container" -}}
{{- $context := .context -}}
{{/* https://github.com/helm/helm/issues/9266 */}}
{{- $value := .container | merge dict -}}
{{- $parent := .parent | merge dict -}}
{{- $name := .name | default $value.name -}}
{{- $securityContext := $value.securityContext | default $value.containerSecurityContext -}}

{{/* Validations */}}
{{- template "base.lib.validate" (dict "template" "base.validate.context" "context" $context) -}}
{{- template "base.lib.validate" (dict "template" "base.validate.containerHasName" "name" $name "context" $context) -}}

name: {{ $name }}
image: {{ template "common.images.image" (dict "imageRoot" $value.image "global" $context.Values.global) }}

{{- if $value | dig "image" "pullPolicy" "" }}
imagePullPolicy: {{ $value.image.pullPolicy }}
{{- end }}

{{- with (include "base.lib.securityContext" (dict "securityContext" $securityContext "parent" $parent.containerSecurityContext)) }}
securityContext: {{ . | nindent 2 }}
{{- end }}

{{- if $value.command }}
command: {{- include "common.tplvalues.render" (dict "value" $value.command "context" $context) | nindent 2 }}
{{- end }}

{{- if $value.args }}
args: {{- include "common.tplvalues.render" (dict "value" $value.args "context" $context) | nindent 2 }}
{{- end }}

{{- if or $value.env $value.extraEnv }}
env:
  {{- include "common.tplvalues.render" (dict "value" $value.env "context" $context) | nindent 2 }}
  {{- include "common.tplvalues.render" (dict "value" $value.extraEnv "context" $context) | nindent 2 }}
{{- end }}

{{- if or $value.envFromCMs $value.envFromSecrets }}
envFrom:
  {{- range $strOrTpl := $value.envFromCMs }}
  - configMapRef:
      name: {{ include "common.tplvalues.render" (dict "value" $strOrTpl "context" $context) }}
  {{- end }}
  {{- range $strOrTpl := $value.envFromSecrets }}
  - secretRef:
      name: {{ include "common.tplvalues.render" (dict "value" $strOrTpl "context" $context) }}
  {{- end }}
{{- end }}

{{- if $value.resources }}
resources: {{- $value.resources | toYaml | nindent 2 -}}
{{- end }}

{{- $ports := list $value.containerPorts $value.ports | compact | first -}}
{{- with (include "base.lib.containerPorts" (dict "ports" $ports "context" $context)) }}
ports: {{- . | indent 2 }}
{{- end }}

{{- if $value | dig "livenessProbe" "enabled" "" }}
livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit $value.livenessProbe "enabled") "context" $context) | nindent 2 }}
{{- end }}

{{- if $value | dig "readinessProbe" "enabled" "" }}
readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit $value.readinessProbe "enabled") "context" $context) | nindent 2 }}
{{- end }}

{{- if $value | dig "startupProbe" "enabled" "" }}
startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit $value.startupProbe "enabled") "context" $context) | nindent 2 }}
{{- end }}

{{- if $value.lifecycleHooks }}
lifecycle: {{- include "common.tplvalues.render" (dict "value" $value.lifecycleHooks "context" $context) | nindent 2 -}}
{{- end }}

{{- with (include "base.lib.volumeMounts" (dict "value" $value "context" $context)) }}
volumeMounts: {{- . | indent 2 }}
{{- end }}

{{- end -}}
