#!/bin/sh

{{- if .Values.adjustLimitMemLock.enabled }}
{{- if not ( "privileged" | get .Values.securityContext | default false ) }}
{{- fail "adjustLimitMemLock is enabled but securityContext is not privileged. Please set securityContext.privileged=true." }}
{{- end }}
ulimit -l {{ int .Values.adjustLimitMemLock.limit }}
{{- end }}
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