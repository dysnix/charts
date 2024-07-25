{{/* vim: set filetype=helm: */}}
{{/*
Includes the given resource. If .values is omitted .top.Values or .top.Values.[component] are
used by default.

Usage
  {{- include "app.resource.include" (dict "resource" "deployment" "component" "" "values" .Values_or_some_path "context" .) -}}
    or
  {{- include "app.resource.include" (dict "resource" "deployment" "component" "" "context" .) -}}
*/}}
{{- define "app.resources.include" -}}
  {{/*
    Global parameters are set in the main component only, but the rest can be set on component level
      - commonLabels
      - commonAnnotations
      - app.name
   */}}
  {{- $global := pick .top.Values "commonLabels" "commonAnnotations" "global" -}}
  {{- $values := .values -}}

  {{/* _include contains resource include parameters and:
          topValues (top-level values)
          Values (component specific values)
  */}}
  {{- $include := dict "topValues" .top.Values -}}
  {{- if and .component (not .values) -}}
    {{- $_ := set $include "Values" (get .top.Values .component) -}}
  {{- else -}}
    {{- $_ := set $include "Values" .top.Values -}}
  {{- end -}}

  {{/*
    Build up the new resource Values.
    Use .values if provided otherwise use .top.Values or .top.Values.[component].
  */}}
  {{- if and .component (not .values) -}}
    {{- $values = get .top.Values .component -}}
  {{- else if not .values -}}
    {{- $values = .top.Values -}}
  {{- end -}}

  {{/* Pass parent values in _include dict. */}}
  {{- $include := dict "_include" (omit . "values" "top" | merge $include) -}}

  {{/* We set the new context for the included resource using .top which always has the full Helm context */}}
  {{- $context := omit .top "Values" "_include" | merge $include -}}
  {{- $context := dict "Values" (mergeOverwrite $values $global) | merge $context -}}
  {{- include (printf "app.resources.%s" .resource) $context -}}
{{- end -}}

{{- define "app.deployment" -}}
  {{- include "app.resources.include" (dict "resource" "deployment" | merge .) -}}
{{- end -}}

{{- define "app.statefulset" -}}
  {{- include "app.resources.include" (dict "resource" "statefulset" | merge .) -}}
{{- end -}}

{{- define "app.service-account" -}}
  {{- include "app.resources.include" (dict "resource" "service-account" | merge .) -}}
{{- end -}}

{{- define "app.service" -}}
  {{- include "app.resources.include" (dict "resource" "service" | merge .) -}}
{{- end -}}

{{- define "app.configmaps" -}}
  {{- include "app.resources.include" (dict "resource" "configmaps" | merge .) -}}
{{- end -}}

{{- define "app.secrets" -}}
  {{- include "app.resources.include" (dict "resource" "secrets" | merge .) -}}
{{- end -}}

{{- define "app.pvc" -}}
  {{- include "app.resources.include" (dict "resource" "pvc" | merge .) -}}
{{- end -}}

{{- define "app.ingress" -}}
  {{- include "app.resources.include" (dict "resource" "ingress" | merge .) -}}
{{- end -}}

{{- define "app.ingress.tls-secret" -}}
  {{- include "app.resources.include" (dict "resource" "ingress.tls-secret" | merge .) -}}
{{- end -}}

{{- define "app.service-monitor" -}}
  {{- include "app.resources.include" (dict "resource" "service-monitor" | merge .) -}}
{{- end -}}

{{- define "app.hpa" -}}
  {{- include "app.resources.include" (dict "resource" "hpa" | merge .) -}}
{{- end -}}

{{- define "app.pdb" -}}
  {{- include "app.resources.include" (dict "resource" "pdb" | merge .) -}}
{{- end -}}

{{- define "app.rbac" -}}
  {{- include "app.resources.include" (dict "resource" "rbac" | merge .) -}}
{{- end -}}
