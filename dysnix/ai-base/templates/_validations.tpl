{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "base.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "base.validateValues.imageRepositoryGiven" .) -}}
{{- $messages := append $messages (include "base.validateValues.noSecretsData" .) -}}
{{- $messages := append $messages (include "base.validateValues.ingressHasPortsProvided" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/* Validate that the container repository name is given */}}
{{- define "base.validateValues.imageRepositoryGiven" -}}
{{- if and (not .Values.image.repository) (has .Values.appKind (list "Deployment" "StatefulSet" "DaemonSet")) -}}
app: no-image-repository
    You did not specify the application image repository. Please
    set image.repository.
{{- end -}}
{{- end -}}

{{/* Validate that secrets have data or stringData given */}}
{{- define "base.validateValues.noSecretsData" -}}
{{- range $_, $values := .Values.secrets -}}
{{- if not (or $values.data $values.stringData) -}}
app: no-secrets-data-or-stringdata
    Each item of .secrets must have data or stringData field. Please
    check the input configuration.
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Validate that the enabled ingress has service ports provided */}}
{{- define "base.validateValues.ingressHasPortsProvided" -}}
{{- if and .Values.ingress.enabled (not (or .Values.service.port .Values.service.ports)) -}}
app: no-service-ports-for-ingress
    You enabled ingress, but did not specify service port or ports. Please set
    service.port or service.ports.
{{- end -}}
{{- end -}}
