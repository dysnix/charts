{{/* vim: set filetype=mustache: */}}

{{/*
  App containers template renders values provided by initContainers/containers.
  It supports:
    - .reuse, .use order and .values for initContainers
    - alphabetical order for ordinary containers
    - reuse=true merges containers with component specific values
        {container specific} > {component specific} > {container base defaults}
    - reuse=false merges containers with component specific values
        {container specific} > {container base defaults}

Usage:
  {{- include "app.containers" (dict "values" .Values.containers "context" $) | nindent 8 }}
  or
  {{- include "app.containers" (dict "initContainers" true "values" .Values.initContainers "context" $) | nindent 8 }}
*/}}
{{- define "app.containers" -}}
  {{/* In nested app.resource.include calls safely use ._include.top */}}
  {{- $top := dig "_include" "top" .context .context -}}
  {{- $order := list -}}
  {{- $values := .values -}}
  {{- $containers := list -}}
  {{- $baseDefaults := $top.Files.Get "container-values.yaml" | fromYaml -}}
  {{- $reuseKeys := list "image" "containerSecurityContext" "command" "args" "env" "envFrom" "volumeMounts" -}}

  {{/* Specify rendering order and pick containers $values */}}
  {{- if .initContainers -}}
    {{- $order = .values.use -}}
    {{- $values = .values.values -}}
  {{- else -}}
    {{- $order = keys .values | sortAlpha -}}
  {{- end -}}

  {{/* Apply rendering order for containers */}}
  {{- range $_, $name := $order -}}
    {{- $container := get $values $name -}}
    {{- if $container -}}
      {{- $container := merge $container (dict "name" $name) $baseDefaults -}}

      {{- if $container.reuse -}}
        {{- range $reuseKeys -}}
          {{/* reuse key is not disabled (the value is nulled), use $.context.Values! */}}
          {{- if not (typeIs "<nil>" (get $container .)) -}}
            {{- $container = merge $container (pick $.context.Values .) (dict "name" $name) $baseDefaults -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}

      {{- $context := dict "_include" (dict "resource" "container" "initContainer" $.initContainers "values" $container "top" $top) -}}
      {{- $containerYaml := include "app.resources.include" $context -}}
      {{- $containers = append $containers ($containerYaml | fromYaml) -}}
    {{- end -}}
  {{- end -}}

  {{- if $containers -}}
    {{- $containers | toYaml -}}
  {{- end -}}
{{- end -}}

{{/*
Genenrate container map configuration
Usage:
  {{ include "app.resources.container" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "app.resources.container" -}}
name: {{ .Values.name }}
image: {{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
imagePullPolicy: {{ .Values.image.pullPolicy }}
{{- if .Values.containerSecurityContext.enabled }}
securityContext: {{- omit .Values.containerSecurityContext "enabled" | toYaml | nindent 12 }}
{{- end }}
{{- if .Values.diagnosticMode.enabled }}
command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 12 }}
{{- else if .Values.command }}
command: {{- include "common.tplvalues.render" (dict "value" .Values.command "context" $) | nindent 12 }}
{{- end }}
{{- if .Values.diagnosticMode.enabled }}
args: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.args "context" $) | nindent 12 }}
{{- else if .Values.args }}
args: {{- include "common.tplvalues.render" (dict "value" .Values.args "context" $) | nindent 12 }}
{{- end }}
env:
  {{- with .Values.env }}
    {{- include "app.tplvalues.named-list" (dict "valueKey" "value" "value" . "toString" true "context" $) | nindent 12 -}}
  {{- end }}
  {{- if .Values.extraEnvVars }}
  {{- include "common.tplvalues.render" (dict "value" .Values.extraEnvVars "context" $) | nindent 12 }}
  {{- end }}
envFrom:
  {{- with .Values.envFrom }}
    {{- include "common.tplvalues.render" (dict "value" . "context" $) | nindent 12 }}
  {{- end }}
  {{- if .Values.extraEnvVarsCM }}
  - configMapRef:
      name: {{ include "common.tplvalues.render" (dict "value" .Values.extraEnvVarsCM "context" $) }}
  {{- end }}
  {{- if .Values.extraEnvVarsSecret }}
  - secretRef:
      name: {{ include "common.tplvalues.render" (dict "value" .Values.extraEnvVarsSecret "context" $) }}
  {{- end }}
{{- if .Values.resources }}
resources: {{- toYaml .Values.resources | nindent 12 }}
{{- end }}
{{- with include "app.tplvalues.named-list" ( dict "value" .Values.containerPorts "valueKey" "containerPort" "context" $) }}
ports:  {{ . | nindent 12 }}
{{- end }}
{{- if and (not .Values.diagnosticMode.enabled) (not ._include.initContainer)  }}
{{- if .Values.customLivenessProbe }}
livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.customLivenessProbe "context" $) | nindent 12 }}
{{- else if .Values.livenessProbe.enabled }}
livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.livenessProbe "enabled") "context" $) | nindent 12 }}
{{- end }}
{{- if .Values.customReadinessProbe }}
readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.customReadinessProbe "context" $) | nindent 12 }}
{{- else if .Values.readinessProbe.enabled }}
readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.readinessProbe "enabled") "context" $) | nindent 12 }}
{{- end }}
{{- if .Values.customStartupProbe }}
startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.customStartupProbe "context" $) | nindent 12 }}
{{- else if .Values.startupProbe.enabled }}
startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.startupProbe "enabled") "context" $) | nindent 12 }}
{{- end }}
{{- end }}
{{- if and .Values.lifecycleHooks (not ._include.initContainer) }}
lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.lifecycleHooks "context" $) | nindent 12 }}
{{- end }}
volumeMounts:
  {{- with .Values.volumeMounts }}
    {{- include "app.tplvalues.named-list" (dict "value" . "context" $) | nindent 12 -}}
  {{- end }}
  {{- if .Values.extraVolumeMounts }}
    {{- include "common.tplvalues.render" (dict "value" .Values.extraVolumeMounts "context" $) | nindent 12 }}
  {{- end }}
{{- end -}}