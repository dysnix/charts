{{/* vim: set filetype=mustache: */}}

{{/*
Recursively render an object value that contains template. Improves bitnami common.tplvalues.render.

Usage:
  {{ include "common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "common.tplvalues.render" -}}
  {{/* render maps */}}
  {{- if kindIs "map" .value -}}
    {{- $dict := dict -}}
    {{- range $key, $val := .value -}}
      {{- $result := list -}}

      {{/* directly processed types can not be unmarshaled back fromYaml  */}}
      {{- if has (kindOf $val) (list "float64" "slice") -}}
        {{- $result = append $result $val -}}
      {{- else if kindIs "map" $val -}}
        {{- $rendered := include "common.tplvalues.render" (dict "value" $val "context" $.context) -}}
        {{- $unmarshalled := $rendered | fromYaml -}}

        {{- if kindIs "map" $unmarshalled -}}
          {{- if hasKey $unmarshalled "Error" -}}
            {{- $source := dict "key" $val -}}
            {{- $unmarshalled = tpl (dict "key" $val | toYaml) $.context | fromYaml -}}
            {{- $result = append $result (get $unmarshalled "key") -}}
          {{- else -}}
            {{- $result = append $result $unmarshalled  -}}
          {{- end -}}

        {{- else -}}
          {{- $result = append $result $rendered -}}
        {{- end -}}

      {{- else if kindIs "string" $val -}}
        {{- $result = append $result (tpl $val $.context) -}}
      {{- else -}}
        {{- $result = append $result $val -}}
      {{- end -}}

      {{- $_ := set $dict $key ($result | first) -}}
    {{- end -}}

{{ tpl ($dict | toYaml) .context -}}

  {{- else if kindIs "string" .value -}}

{{ tpl .value .context -}}

  {{- else -}}

{{ tpl (.value | toYaml) .context -}}

  {{- end -}}
{{- end -}}

{{/*
Renders a generic ordreder list (not for a directl use).

Usage:
  {{ include "app.tplvalues.render._list" (dict "use" SomeList "values" ValuesMap "context" $) }}
*/}}
{{- define "app.tplvalues._list" -}}
  {{- $items := list -}}

  {{- range $_, $name := .use | default list -}}
    {{- $value := get $.values $name -}}

    {{- if eq "string" (kindOf $value) -}}
      {{- $value = include "common.tplvalues.render" (dict "value" $value "context" $.context) -}}
    {{- end -}}

    {{- if eq "map" (kindOf $value) -}}
      {{- $value = dict "name" $name | merge $value -}}
    {{- else if and $value $.valueKey -}}
      {{- $value = ternary $value ($value | toString) (not $.toString) -}}
      {{- $value = dict "name" $name $.valueKey $value -}}
    {{- end -}}

    {{- if $value -}}
      {{- $items = append $items $value -}}
    {{- end -}}
  {{- end -}}

  {{- if $items -}}
    {{- include "common.tplvalues.render" (dict "value" $items "context" $.context) -}}
  {{- end -}}
{{- end -}}

{{/*
ordered-list generates a list from a map with (use and values keys), where use and values correspondingly define the order and
the values. This template can be used for data which must maintain a specific order such as initContainers for example.

Values example:
app:
  initContainers:
    use:
      - skip
      - foo
    values:
      skip: null
      foo:
        image: docker.io/foo
        imagePullPolicy: IfNotPresent

Usage:
  {{ include "app.tplvalues.render.ordered-list" ( dict "value" .Values.containerPorts "valueKey" "containerPort" "context" $) }}
*/}}
{{- define "app.tplvalues.ordered-list" -}}
  {{- $value := default dict .value -}}
  {{- include "app.tplvalues._list" (dict "use" $value.use "values" $value.values "toString" .toString "context" .context) -}}
{{- end -}}

{{/*
named-list renders a map as a list. The key list is alphabetically sorted, this maintains order for such kind of lists.
Such aproach is acceptable for env, ports lists, morover there are extra* parameters for lists such as extraEnvVars etc.
The extra parameters are true list and can be used as well.

Values example:
  env:
    HELLO: WORLD
    FOO: appears-in-the-list-before-HELLO

Usage:
  {{ include "app.tplvalues.render.named-list" ( dict "value" .Values.app.initContainer "context" $) }}
*/}}
{{- define "app.tplvalues.named-list" -}}
  {{- if kindIs "map" .value  -}}
    {{- include "app.tplvalues._list" (dict "use" (keys .value | sortAlpha) "values" .value "valueKey" .valueKey "toString" .toString "context" .context) -}}
  {{- end -}}
{{- end -}}