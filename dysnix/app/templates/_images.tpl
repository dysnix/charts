{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper Docker Image Registry Secret Names (fallback to top .image for components)
*/}}
{{- define "app.imagePullSecrets" -}}
  {{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Return the proper image name
{{ include "common.images.image" ( dict "imageRoot" .Values.path.to.the.image "global" $) }}
*/}}
{{- define "common.images.image" -}}
  {{- $registry := .imageRoot.registry -}}
  {{- $repository := .imageRoot.repository -}}
  {{- $termination := "" -}}
  {{- if .global -}}
    {{- if .global.imageRegistry -}}
      {{- $registry = .global.imageRegistry -}}
    {{- end -}}
  {{- end -}}
  {{- if .imageRoot.digest -}}
    {{- $termination = printf "@%s" (.imageRoot.digest | toString) -}}
  {{- else if .imageRoot.tag -}}
    {{- $termination = printf ":%s" (.imageRoot.tag | toString) -}}
  {{- end -}}
  {{- list $registry (printf "%s%s" $repository $termination) | compact | join "/" -}}
{{- end -}}