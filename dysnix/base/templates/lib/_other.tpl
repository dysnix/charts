{{/* vim: set filetype=mustache: */}}

{{/*
Generate a resource fullname (produces the fullname-name)

Usage:
  {{- include "base.fullname" (dict "value" .Values.path.to.dict "name" "override" "context" $) }}

Params:
  value - (optional) Dict with a resource definition. The Dict might/might not contain .name.
  name - (optional) resource name to use, overrides .value.name
*/}}
{{- define "base.fullname" }}
  {{- $name :=  get (default (dict) .value) "name" | default .name | default "" -}}
  {{- $component := get (default (dict) .value) "component" | default .component | default "" -}}

  {{/* add common fullname (without component or name part added) */}}
  {{- $name_list := list (include "common.names.fullname" .context) -}}

  {{/* skip default component part _default */}}
  {{- if ne "_default" $component -}}
    {{- $name_list = append $name_list $component -}}
  {{- end -}}

  {{/* add the closing name part*/}}
  {{- $name_list = append $name_list $name -}}

  {{- $name_list | compact | join "-" -}}
{{- end -}}

{{/*
Usage:
  {{- include "base.serviceAccountName" (dict "serviceAccount" .Values.path.serviceAccount "component" "foo" "context" $) -}}

Params:
  serviceAccount - value dict
  context - render context (root is propogated - $)
  name - (optional) suplemental name for ServiceAccount
  component - (optional) specifies the component name (used for naming and labeling)
*/}}
{{- define "base.serviceAccountName" -}}
  {{- $sa := .serviceAccount | default dict -}}
  {{- if $sa.create -}}
    {{- include "base.fullname" (dict "name" .name "component" .component "context" .context) -}}
  {{- else -}}
    {{- $sa.name | default "default" -}}
  {{- end -}}
{{- end -}}

{{/*
Render securityContext for a pod or a container.
If parent is provided, it's used as the default securityContext.

Usage:
  {{ include "base.securityContext" (dict "securityContext" .securityContext "parent" .containerSecurityContext) }}
*/}}
{{- define "base.securityContext" -}}
  {{- $sc := .securityContext | default dict -}}
  {{- $parent := .parent | default dict -}}
  {{- if and $parent.enabled $parent.propogated -}}
    {{- $sc = mergeOverwrite ($parent | deepCopy) $sc -}}
  {{- end -}}
  {{- if $sc.enabled -}}
    {{- omit $sc "enabled" "propogated" | toYaml -}}
  {{- end -}}
{{- end -}}
