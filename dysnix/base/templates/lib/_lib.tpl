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
