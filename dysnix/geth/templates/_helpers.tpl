{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "geth.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "geth.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "geth.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Geth statefullset annotations
*/}}
{{- define "geth.statefulset.annotations" -}}
{{- if .Values.persistence.snapshotValue -}}
snapshot: {{ .Values.persistence.snapshotValue }}
{{- end -}}
{{- end -}}

{{/*
Geth args
*/}}
{{- define "geth.args" -}}

{{- $customArgs := list -}}
{{- $args := list "--maxpeers" .Values.maxPeers "--cache" .Values.cache -}}
{{- $args = concat $args (list "--syncmode" .Values.syncMode "--pprof" "--pprof.addr=0.0.0.0") -}}
{{- $args = concat $args (list "--pprof.port=6060" "--metrics" "--http" "--http.api" .Values.http.api) -}}
{{- $args = concat $args (list "--http.addr" "0.0.0.0" "--http.port" .Values.http.port "--http.vhosts" .Values.http.vhosts) -}}
{{- $args = concat $args (list "--http.corsdomain" "*" "--ws" "--ws.addr" "0.0.0.0" "--ws.port" .Values.ws.port) -}}
{{- $args = concat $args (list "--ws.api" .Values.ws.api "--ws.origins" .Values.ws.origins) -}}
{{- $args = concat $args (list "--port" .Values.p2p.port "--discovery.port" .Values.p2p.discoveryPort) -}}
{{- if .Values.authrpc.enabled }}
{{- $args = concat $args (list "--authrpc.addr=0.0.0.0"  "--authrpc.port" .Values.authrpc.port ) -}}
{{- $args = concat $args (list "--authrpc.vhosts" .Values.authrpc.vhosts ) -}}
{{- $args = concat $args (list "--authrpc.jwtsecret" .Values.authrpc.jwtpath ) -}}
{{- end -}}
{{- if .Values.p2p.nat }}
{{- $args = concat $args (list "--nat" .Values.p2p.nat ) -}}
{{- end }}
{{- if gt .Values.maxPendPeers 0 }}
{{- $args = concat $args (list "--maxpendpeers" .Values.maxPendPeers) -}}
{{- end }}

{{- range $testnet := list "ropsten" "rinkeby" "goerli" -}}
  {{- if eq ($testnet | get $.Values | toString) "true"  -}}
    {{- $args = prepend $args ($testnet | printf "--%s") -}}
  {{- end -}}
{{- end -}}

{{- range $k, $v := .Values.customArgs -}}
  {{- $customArgs = concat $customArgs (list ($k | printf "--%s") $v) -}}
{{- end -}}

{{- $mode := "snapshot" | get .Values | toString -}}
{{- if eq $mode "true" -}}
  {{- $args = append $args "--snapshot" -}}
{{- else if eq $mode "false" -}}
  {{- $args = append $args "--snapshot=false" -}}
{{- end -}}

{{- concat $args $customArgs | compact | toStrings | toYaml -}}

{{- end -}}
