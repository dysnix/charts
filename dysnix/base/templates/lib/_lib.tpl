{{/* vim: set filetype=mustache: */}}
{{/*
Generate a resource fullname (produces the fullname-name)

Usage:
  {{- include "base.lib.fullname" (dict "value" .Values.path.to.dict "name" "override" "context" $) }}

Params:
  value - (optional) Dict with a resource definition. The Dict might/might not contain .name.
  name - (optional) resource name to use, overrides .value.name
*/}}
{{- define "base.lib.fullname" }}
  {{- $rn := list (include "common.names.fullname" .context) -}}
  {{/* Ignore .name which equals _default */}}
  {{- if ne "_default" .name -}}
    {{- $rn = append $rn .name -}}
  {{- end -}}

  {{- $rn = append $rn (get (default (dict) .value) "component") -}}
  {{- $rn = append $rn (get (default (dict) .value) "name") -}}

  {{- $rn = $rn | compact -}}
  {{- $slen := gt (len $rn) 1 | ternary 2 1 -}}

  {{- slice $rn 0 $slen | join "-" -}}
{{- end -}}

{{/*
Get component name!
.value.component has precedence over .component.

Usage:
  {{ include "base.lib.component" (dict "value" .path.to.dict "component" .component }}
*/}}
{{- define "base.lib.component" -}}
{{- .value.component | default .component -}}
{{- end -}}

{{/*
Validate template prints formated validation error and fails.

Usage:
  {{- template "base.lib.validate" (dict "template" "base.validate.containerName" "key" "FOO" "another" "BAR" "context" $) -}}

Params
  template - the validation template which provides an error message
  . - context for the validation template (template itself is omitted)
*/}}
{{- define "base.lib.validate" -}}
  {{- $error := include .template (omit . "template") -}}
  {{- if $error -}}
    {{- printf "\n\n==> Chart `%s' validation failed!\n==> %s" "xxx" $error | fail -}}
  {{- end -}}
{{- end -}}

{{/*
Render securityContext for a pod or a container.
If parent is provided, it's used as the default securityContext.

Usage:
  {{ include "base.lib.securityContext" (dict "securityContext" .securityContext "parent" .containerSecurityContext) }}
*/}}
{{- define "base.lib.securityContext" -}}
  {{- $sc := .securityContext | default dict -}}
  {{- $parent := .parent | default dict -}}
  {{- if and $parent.enabled $parent.propogated -}}
    {{- $sc = mergeOverwrite ($parent | deepCopy) $sc -}}
  {{- end -}}
  {{- if $sc.enabled -}}
    {{- omit $sc "enabled" "propogated" | toYaml -}}
  {{- end -}}
{{- end -}}

{{/*
Container ports section
ref: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#containerport-v1-core

Usage:
  {{ include "base.lib.containerPorts" (dict "ports" .Values.containerPorts "context" $) }}

Params:
  ports - container ports object, dict or list
  context - template render context

Ports can have a dict form, e.g.
  http: 80
  https: 443
in this case all port numbers refer to the default protocol which is TCP.

Note: for finegrained controll use the list form (for e.g to specify protocol or targetPort)
*/}}
{{- define "base.lib.containerPorts" -}}
  {{- if and .ports (kindIs "map" .ports) -}}
    {{- range $name, $port := .ports }}
- name: {{ $name }}
  containerPort: {{ $port | int }}
    {{- end }}
  {{- else if .ports -}}
    {{- range $item := .ports }}
- name: {{ $item.name }}
  {{- include "common.tplvalues.render" (dict "value" (omit $item "name") "context" $.context) | nindent 2 }}
    {{- end }}
  {{- end -}}
{{- end -}}

{{/*
Container volumeMounts section

Usage
  {{- include "base.lib.volumeMounts" (dict "value" $value "context" $context) | nindent 2 }}

Params:
  value - value dict containing persistence
  context - render context (root is propogated - $)
*/}}
{{- define "base.lib.volumeMounts" -}}
  {{- $context := .context -}}
  {{- $value := .value -}}
  {{- $persistence := .value | merge dict | dig "persistence" dict -}}
  {{- template "base.lib.validate" (dict "template" "base.validate.context" "context" $context) -}}

  {{- if $persistence.enabled }}
    {{- $mount := pick $persistence "volumeName" "mountPath" "mountPropagation" "readOnly" "subPath" "subPathExpr" -}}
    {{- with merge (dict "name" $mount.volumeName) (omit $mount "volumeName") }}
      {{- include "common.tplvalues.render" (dict "value" (list .) "context" $context) | nindent 0 }}
    {{- end }}
  {{- end }}

  {{- with $value.volumeMounts }}
    {{- include "common.tplvalues.render" (dict "value" . "context" $context) | nindent 0 }}
  {{- end }}

  {{- with $value.extraVolumeMounts }}
    {{- include "common.tplvalues.render" (dict "value" . "context" $context) | nindent 0 }}
  {{- end }}
{{- end -}}

{{/*
Pod volumes section

Usage
  {{- include "base.lib.volumes" (dict "value" $value "context" $context) | nindent 2 }}

Params:
  value - value dict containing persistence
  context - render context (root is propogated - $)
  name - (optinal) volume name (by default .value.volumeName is used)
  component - (optional) specifies the component name (used for naming and labeling)
*/}}
{{- define "base.lib.volumes" -}}
  {{- $value := .value -}}
  {{- $context := .context -}}
  {{- $persistence := .value | merge dict | dig "persistence" dict -}}
  {{- $component := .component | default "" -}}
  {{- $name := .name | default $persistence.volumeName -}}
  {{- template "base.lib.validate" (dict "template" "base.validate.context" "context" $context) -}}

  {{- if $persistence.enabled }}
- name: {{ $name }}
  persistentVolumeClaim:
    claimName: {{ include "base.lib.fullname" (dict "value" $value "name" $name "component" $component "context" $context) }}
  {{- end }}

  {{- with $value.volumes }}
    {{- include "common.tplvalues.render" (dict "value" . "context" $context) | nindent 0 }}
  {{- end }}

  {{- with $value.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" . "context" $context) | nindent 0 }}
  {{- end }}
{{- end -}}
