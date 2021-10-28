{{/* vim: set filetype=mustache: */}}

{{- define "base.validate.containerHasName" -}}
{{- if empty .name -}}
Container name is empty!

Please provide .name or .value.name to the template!
Note: check that all .podContainers item have .name attribute.
{{- end -}}
{{- end -}}

{{- define "base.validate.controllerSupported" -}}
{{- $supported := list ("deployment") -}}
{{- if not (has .controller (list "deployment")) -}}
Unsupported controller type!

Type `{{ .controller }}` was provided. Please use one from the bellow list:
  {{ $supported | join ", " }}
{{- end -}}
{{- end -}}

{{- define "base.validate.componentGiven" -}}
{{- if empty .component -}}
.component is not provided!

Make sure to specify .path.to.dict.component
{{- end -}}
{{- end -}}

{{- define "base.validate.context" -}}
{{- if not (hasKey (default (dict) .context) "Values") -}}
.context is not valid!

Make sure to pass $ object, containing .Values as the context
{{- end -}}
{{- end -}}
