{{/* vim: set filetype=mustache: */}}
{{/*
Return the proper NGINX image name
*/}}
{{- define "nginx.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper GIT image name
*/}}
{{- define "nginx.cloneStaticSiteFromGit.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.cloneStaticSiteFromGit.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker image repository name
*/}}
{{- define "nginx.fetchStaticSiteFromDockerImage.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.fetchStaticSiteFromDockerImage.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper DAP Auth Daemon image name
*/}}
{{- define "nginx.ldapDaemon.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.ldapDaemon.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Prometheus metrics image name
*/}}
{{- define "nginx.metrics.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.metrics.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "nginx.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.cloneStaticSiteFromGit.image .Values.fetchStaticSiteFromDockerImage.image .Values.ldapDaemon.image .Values.metrics.image) "global" .Values.global) }}
{{- end -}}

{{/*
Return true if a static site should be mounted in the NGINX container
*/}}
{{- define "nginx.useStaticSite" -}}
{{- if or .Values.cloneStaticSiteFromGit.enabled .Values.fetchStaticSiteFromDockerImage.enabled .Values.staticSiteConfigmap .Values.staticSitePVC }}
    {- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the volume to use to mount the static site in the NGINX container
*/}}
{{- define "nginx.staticSiteVolume" -}}
{{- if or .Values.cloneStaticSiteFromGit.enabled .Values.fetchStaticSiteFromDockerImage.enabled }}
emptyDir: {}
{{- else if .Values.staticSiteConfigmap }}
configMap:
  name: {{ .Values.staticSiteConfigmap }}
{{- else if .Values.staticSitePVC }}
persistentVolumeClaim:
  claimName: {{ .Values.staticSitePVC }}
{{- end }}
{{- end -}}

{{/*
Return the custom NGINX server block configmap.
*/}}
{{- define "nginx.serverBlockConfigmapName" -}}
{{- if .Values.existingServerBlockConfigmap -}}
    {{- printf "%s" (tpl .Values.existingServerBlockConfigmap $) -}}
{{- else -}}
    {{- printf "%s-server-block" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the custom NGINX server block secret for LDAP.
*/}}
{{- define "ldap.nginxServerBlockSecret" -}}
{{- if .Values.ldapDaemon.existingNginxServerBlockSecret -}}
    {{- printf "%s" (tpl .Values.ldapDaemon.existingNginxServerBlockSecret $) -}}
{{- else -}}
    {{- printf "%s-ldap-daemon" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "nginx.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "nginx.validateValues.cloneStaticSiteFromGit" .) -}}
{{- $messages := append $messages (include "nginx.validateValues.fetchStaticSiteFromDockerImage" .) -}}
{{- $messages := append $messages (include "nginx.validateValues.staticSites" .) -}}
{{- $messages := append $messages (include "nginx.validateValues.extraVolumes" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/* Validate values of NGINX - Clone StaticSite from Git configuration */}}
{{- define "nginx.validateValues.cloneStaticSiteFromGit" -}}
{{- if and .Values.cloneStaticSiteFromGit.enabled (or (not .Values.cloneStaticSiteFromGit.repository) (not .Values.cloneStaticSiteFromGit.branch)) -}}
nginx: cloneStaticSiteFromGit
    When enabling cloing a static site from a Git repository, both the Git repository and the Git branch must be provided.
    Please provide them by setting the `cloneStaticSiteFromGit.repository` and `cloneStaticSiteFromGit.branch` parameters.
{{- end -}}
{{- end -}}

{{/* Validate values of NGINX - Fetch StaticSite from Docker Image configuration */}}
{{- define "nginx.validateValues.fetchStaticSiteFromDockerImage" -}}
{{- if and .Values.fetchStaticSiteFromDockerImage.enabled (not .Values.fetchStaticSiteFromDockerImage.directory) -}}
nginx: fetchStaticSiteFromDockerImage
    When enabling fetching a static site from a Docker image static site directory must be provided.
    Please provide it by setting the `fetchStaticSiteFromDockerImage.directory` parameter.
{{- end -}}
{{- end -}}

{{/* Validate values of NGINX - static sites configuration */}}
{{- define "nginx.validateValues.staticSites" -}}
{{- if and .Values.cloneStaticSiteFromGit.enabled .Values.fetchStaticSiteFromDockerImage.enabled -}}
nginx: conflicting cloneStaticSiteFromGit, fetchStaticSiteFromDockerImage
    When enabling cloning or fetching a static site one option must be enabled.
    Please set either of parameters `cloneStaticSiteFromGit.enabled` or `fetchStaticSiteFromDockerImage.enabled` to false.
{{- end -}}
{{- end -}}

{{/* Validate values of NGINX - Incorrect extra volume settings */}}
{{- define "nginx.validateValues.extraVolumes" -}}
{{- if and (.Values.extraVolumes) (not .Values.extraVolumeMounts) -}}
nginx: missing-extra-volume-mounts
    You specified extra volumes but not mount points for them. Please set
    the extraVolumeMounts value
{{- end -}}
{{- end -}}
