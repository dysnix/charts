{{/* vim: set filetype=helm: */}}
{{/*
Includes the given resource from the app chart templates.
Note that if component is not provided we assume it's default.

Usage
  {{- include "app.resource.include" (dict "_include" (dict "resource" "deployment" "top" $) }}
  {{- include "app.resource.include" (dict "_include" (dict "resource" "deployment" "component" "foo" "values" .Path.Values "top" $)) }}

  It also supports custom parameters, especially used during nested invocations such
  as in configmaps or secrets. Pay attention to mergeOverwrite since we need to
  overwrite existing the _include fields (including resource).

  {{- include "app.resources.include" (dict "_include" (dict "resource" "configmap" "name" $name "data" $data) | mergeOverwrite $) }}
*/}}
{{- define "app.resources.include" -}}
  {{/* Don't require top on nested runs, use _include.top */}}
  {{- if not (all ._include.resource ._include.top) -}}
    {{- keys ._include | toYaml | fail -}}
    {{- "_include.{resource,top} must be provided" | fail -}}
  {{- end -}}

  {{/* Set empty paths for the default component or if it's passed */}}
  {{- $componentPaths := ternary (dict "" true) (dict .component true "" true) (empty .component)   -}}
  {{/* Give precedence to .Values.app.components path settings */}}
  {{- $componentPaths = default dict ._include.top.Values.app.components | mergeOverwrite $componentPaths -}}
  {{- $path := get $componentPaths (default "" ._include.component) | toString -}}

  {{/* Path is enabled, so is the component */}}
  {{- if ne $path "false" -}}
    {{- $baseDefaults := ._include.top.Files.Get "component-values.yaml" | fromYaml -}}
    {{- $componentValues := ternary ._include.top.Values ($path | get ._include.top.Values) (eq $path "true") -}}

    {{- /* Component's values can be provided explicitly via ._include.values */ -}}
    {{- if not (any $componentValues ._include.values) -}}
      {{- $pathstr := $path | printf ".Values.%s" | trimSuffix "." -}}
      {{- printf "Component %s has no values at path %s" ._include.component $pathstr | fail -}}
    {{- end -}}
    {{- $componentValues = ._include.values | default $componentValues | mergeOverwrite $baseDefaults -}}

    {{/* Specific global values are always injected into the render context */}}
    {{- $global := pick ._include.top.Values "commonLabels" "commonAnnotations" "global" -}}
    {{- $values := $global | mergeOverwrite $componentValues -}}

    {{- $context := omit ._include.top "Values" | merge (dict "Values" $values "_include" ._include) -}}
    {{- include (printf "app.resources.%s" ._include.resource) $context  -}}
  {{- end -}}
{{- end -}}

{{/*
Function renders app resource template files (eg. deployments).
It's a wrapper to app.resources.include and all its supported parameters can be passed!

For example if we want to render the deployment resource it's recommended to
place the code into deployment.yaml, the resource name "deployment"
automatically picked from the file name.

Placing the include statement into the specific file provides the following benefits:
  - Automatic resource name detection
  - Resource render is bound to the given file, thus during the render
    line `# Source .../templates/{resource}.yaml` is explicit.

Note by default the default component is rendererd only. Use the extended form
to render more components or if need to provide a specific resource template.

Usage:
  Renderer the resource template for the default component
  {{- include "app.template" . -}}
  {{- include "app.template" (dict "resource" "pvc" "top" $) -}}
  {{- include "app.template" (dict "resource" "pvc" "component" "foo" "values" .Path.to.values "top" $) -}}
```
*/}}
{{- define "app.template" -}}
  {{- $top := . | default .top -}}

  {{/* Pick the resource or detect automatically */}}
  {{- $defaultResource := .Template.Name | base | trimSuffix ".yaml" -}}
  {{- $resource := ternary $defaultResource .resource (empty .resource) -}}

  {{/* Define context */}}
  {{- $include := dict "resource" $resource "top" $top "values" .values -}}

  {{/* Set empty paths for the default component or if it's passed */}}
  {{- $componentPaths := ternary (dict "" true) (dict .component true "" true) (empty .component)   -}}
  {{/* Give precedence to .Values.app.components path settings */}}
  {{- $componentPaths = default dict $top.Values.app.components | mergeOverwrite $componentPaths -}}

  {{/* Render all components which are not explicitly disabled */}}
  {{- range $component := keys $componentPaths | sortAlpha -}}
    {{- $path := get $componentPaths $component | toString -}}
    {{- if ne $path "false" -}}
      {{- $context := dict "_include" ($include | merge (dict "component" $component)) -}}
      {{- include "app.resources.include" $context -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
