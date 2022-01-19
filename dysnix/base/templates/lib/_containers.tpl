{{/* vim: set filetype=mustache: */}}
{{/*
Kubernetes containers list

Usage:
  {{- include "base.containers.podContainers" (dict "value" .Values.path.to.dict "context" $) -}}

Params:
  value - value (dict) com
  component - specifies the component name (used for naming and labeling)
  context - template render context
*/}}
{{- define "base.containers.podContainers" -}}
  {{- $context := .context -}}
  {{- $value := .value -}}
  {{- $component := .component -}}
  {{- $name_list := list -}}

  {{- template "base.validate" (dict "template" "base.validate.context" "context" $context) -}}

  {{- if eq "_default" $component -}}
    {{- $name_list = append $name_list $context.Chart.Name -}}
  {{- end -}}
  {{- $name_list = append $name_list $component -}}

- {{- include "base.container" (dict "container" $value "name" ($name_list | first) "context" $context) | nindent 2 }}

  {{- range $container := $value.podContainers }}
-   {{- include "base.container" (dict "container" $container "parent" $value "context" $context) | nindent 2 }}
  {{- end }}

  {{- with include "base.tpl.flatlist" (dict "value" (list $value.sidecars) "context" $context) }}
    {{ . | nindent 0 }}
  {{- end }}

{{- end -}}

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
{{- $name := .name | default $value.name | default $context.Chart.Name -}}
{{- $securityContext := $value.securityContext | default $value.containerSecurityContext -}}

{{/* Validations */}}
{{- template "base.validate" (dict "template" "base.validate.context" "context" $context) -}}
{{- template "base.validate" (dict "template" "base.validate.containerHasName" "name" $name "context" $context) -}}

name: {{ $name }}
image: {{ template "common.images.image" (dict "imageRoot" $value.image "global" $context.Values.global) }}

{{- if $value | dig "image" "pullPolicy" "" }}
imagePullPolicy: {{ $value.image.pullPolicy }}
{{- end }}

{{- with (include "base.securityContext" (dict "securityContext" $securityContext "parent" $parent.containerSecurityContext)) }}
securityContext: {{ . | nindent 2 }}
{{- end }}

{{- if $value.command }}
command: {{- include "common.tplvalues.render" (dict "value" $value.command "context" $context) | nindent 2 }}
{{- end }}

{{- with include "base.tpl.flatlist" (dict "value" (list $value.args $value.extraArgs) "context" $context) }}
args: {{- . | nindent 2 }}
{{- end }}

{{- with include "base.tpl.flatlist" (dict "value" (list $value.env $value.extraEnv) "context" $context) }}
env: {{- . | nindent 2 }}
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
{{- with (include "base.ports.containerPorts" (dict "ports" $ports "context" $context)) }}
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

{{- with (include "base.volumes.volumeMounts" (dict "value" $value "context" $context)) }}
volumeMounts: {{- . | indent 2 }}
{{- end }}

{{- end -}}
