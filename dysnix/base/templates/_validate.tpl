{{/* vim: set filetype=mustache: */}}

{{/*
Validate template prints formated validation error and fails.

Usage:
  {{- template "base.validate" (dict "template" "base.validate.containerName" "key" "FOO" "another" "BAR" "context" $) -}}

Params
  template - the validation template which provides an error message
  . - context for the validation template (template itself is omitted)
*/}}
{{- define "base.validate" -}}
  {{- $error := include .template (omit . "template") -}}
  {{- if $error -}}
    {{- printf "\n\n===> Chart `%s' validation failed!\n===> %s" "xxx" $error | fail -}}
  {{- end -}}
{{- end -}}

{{- define "base.validate.containerHasName" -}}
{{- if empty .name -}}
Container name is empty!
  
  Please provide .name or .value.name to the template!
  Note: check that all .podContainers item have .name attribute.
{{- end -}}
{{- end -}}

{{- define "base.validate.controllerSupported" -}}
{{- $supported := list ("Deployment") -}}
{{- if not (has .controller $supported) -}}
Unsupported controller type!
  
  Type `{{ .controller }}` was provided. Please use one from the bellow list:
    {{ $supported | join ", " }}
{{- end -}}
{{- end -}}

{{- define "base.validate.context" -}}
{{- if not (hasKey (default (dict) .context) "Values") -}}
.context is not valid!
  
  Make sure to pass $ object, containing .Values as the context
{{- end -}}
{{- end -}}

{{- define "base.validate.containerPortNotFound" -}}
no container ports!
  
  Could not find port with the name `{{ .name }}' in
    - .containerPorts
    - .podContainers.*.ports
    - .sidecar.*.ports
  Failed!
{{- end -}}

{{- define "base.validate.ingressBackendPortEmpty" -}}
{{- if not .port -}}
.servicePort is empty!

  .servicePort or .ingress.servicePort must be provided!
{{- end -}}
{{- end -}}
