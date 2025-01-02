#!/bin/sh

exec agave-validator
    {{- range $arg, $val := .Values.agaveArgs }}
      {{- if and $arg (or $val (and (kindIs "float64" $val) (eq (int $val) 0))) }} \{{ end }}
      {{- if kindIs "float64" $val }}
    --{{ $arg }}={{ int $val }}
      {{- else if kindIs "bool" $val }}
        {{- if $val }}
    --{{ $arg }}
        {{- end }}
      {{- else if kindIs "slice" $val }}
        {{- range $key, $nestedVal := $val }}
          {{- if $key }} \{{ end }}
    --{{ $arg }}={{ $nestedVal }}
        {{- end }}
      {{- else }}
    --{{ $arg }}={{ $val }}
      {{- end }}
    {{- end }}