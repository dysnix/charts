{{- define "ton.volumeMountsTemplate" -}}
- name: data
  mountPath: {{ $.Values.config.fullnode.root }}
- name: archive
  mountPath: {{ $.Values.config.fullnode.root }}/archive
{{- end }}


{{- define "ton.volumesTemplate" }}
{{- with $.Values.persistance }}
  {{- if (and (hasKey . "data") (not (empty .data))) }}
    {{- if eq .data.type "hostPath" }}
- name: data
  hostPath:
    path: {{ required "persistance.data.path required" .data.path }}
    type: {{ .data.perm | default "DirectoryOrCreate" }}
    {{- end }}
  {{- end }}
  {{- if (and (hasKey . "archive") (not (empty .archive))) }}
    {{- if eq .archive.type "hostPath" }}
- name: archive
  hostPath:
    path: {{ required "persistance.archive.path required" .archive.path }}
    type: {{ .archive.perm | default "DirectoryOrCreate" }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}


{{- define "ton.valoumeClainmTemplates" }}
{{- with $.Values.permistance }}
{{- if (and (hasKey . "data") (not (empty .data))) }}
    {{- if eq .data.type "pvc" }}
- name: data
  label:
    app.kubernetes.io/name: {{ include "ton.name" . }}
    app.kubernetes.io/instance: {{ $.Release.Name }}
  annotations:
    {{- if .data.annotations }}
    {{- toYaml .data.annotations | nindent 4 }}
    {{- end }}
  accessModes:
    - {{ .data.accessMode | default "ReadWriteOnce" }}
  storageClassName: {{ .data.storageClassName | default "" }}
  resources:
    requests:
      storage: {{ .data.size }}
{{- end }}
{{- end }}
{{- if .archive -}}
{{- if eq .archive.type "pvc" -}}
- name: data
  label:
    app.kubernetes.io/name: {{ include "ton.name" . }}
    app.kubernetes.io/instance: {{ $.Release.Name }}
  annotations:
    {{- if .archive.annotations }}
    {{- toYaml .archive.annotations | nindent 4 }}
    {{- end }}
  accessModes:
    - {{ .archive.accessMode | default "ReadWriteOnce" }}
  storageClassName: {{ .archive.storageClassName | default "" }}
  resources:
    requests:
      storage: {{ .archive.size }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

