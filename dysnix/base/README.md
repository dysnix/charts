# Base

[base](https://github.com/bitnami-labs/kubewatch) is a library Helm chart. It's aim is to provide the value interface for dependent
charts.

## TL;DR

Create a chart from dysnix base:

```console
CHART_NAME=mychart
mkdir -p $CHART_NAME/templates
( cd $CHART_NAME;  curl -sSO# https://raw.githubusercontent.com/dysnix/charts/main/dysnix/base/values.yaml )

cat <<EHD > $CHART_NAME/Chart.yaml
apiVersion: v2
name: $CHART_NAME
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "0.1.0"
dependencies:
  - name: common
    repository: https://charts.bitnami.com/bitnami
    tags:
      - bitnami-common
    version: 1.10.x
  - name: base
    version: 0.1.x
    repository: https://dysnix.github.io/charts
    tags:
      - dysnix-base
EHD

cat <<EHD > $CHART_NAME/templates/all.yaml
{{/* vim: set filetype=mustache: */}}
{{- include "base.all" $ -}}
EHD
```

## Introduction

This chart provides library templates which are meant to deploy various number of [Kubernetes](http://kubernetes.io) resources using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.18+
- Helm 3.5.0

## Chart configuration

The [Parameters](#parameters) section provides a wide set parameters to configure the bahaviour of the dependant chart. Modify values.yaml to define resources configuration logic specific for the chart being developed.

## Parameters

### Global parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `global.imageRegistry`    | Global Docker image registry                    | `""`  |
| `global.imagePullSecrets` | Global Docker registry secret names as an array | `[]`  |
| `global.storageClass`     | Global StorageClass for Persistent Volume(s)    | `""`  |


### Common parameters for all deployed objects

| Name                | Description                                                                                  | Value           |
| ------------------- | -------------------------------------------------------------------------------------------- | --------------- |
| `kubeVersion`       | Override Kubernetes version                                                                  | `""`            |
| `nameOverride`      | String to partially override common.names.fullname template (will maintain the release name) | `""`            |
| `fullnameOverride`  | String to fully override common.names.fullname template                                      | `""`            |
| `commonLabels`      | Labels to add to all deployed objects                                                        | `{}`            |
| `commonAnnotations` | Annotations to add to all deployed objects                                                   | `{}`            |
| `clusterDomain`     | Kubernetes cluster domain name                                                               | `cluster.local` |
| `extraDeploy`       | (TBI) Array of extra objects to deploy with the release                                      | `[]`            |


### Default Pod parameters

| Name                    | Description                 | Value        |
| ----------------------- | --------------------------- | ------------ |
| `defaultPod.enabled`    | Create the default Pod      | `true`       |
| `defaultPod.controller` | Default Pod controller type | `deployment` |


### Pod(s) specific parameters

| Name                                    | Description                                                                                         | Value           |
| --------------------------------------- | --------------------------------------------------------------------------------------------------- | --------------- |
| `image.registry`                        | Image registry                                                                                      | `""`            |
| `image.repository`                      | Image name                                                                                          | `foo/bar`       |
| `image.tag`                             | Image tag                                                                                           | `latest`        |
| `image.pullPolicy`                      | Image pull policy                                                                                   | `""`            |
| `image.pullSecrets`                     | Image pull secrets                                                                                  | `[]`            |
| `replicaCount`                          | Number of pod replicas to deploy                                                                    | `1`             |
| `containerPorts`                        | Container Ports definition (map is also supported)                                                  | `[]`            |
| `livenessProbe.enabled`                 | Enable livenessProbe on containers                                                                  | `false`         |
| `livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                                             | `20`            |
| `livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                                    | `10`            |
| `livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                                   | `5`             |
| `livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                                 | `3`             |
| `livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                                 | `1`             |
| `readinessProbe.enabled`                | Enable readinessProbe on containers                                                                 | `false`         |
| `readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                                            | `20`            |
| `readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                                   | `10`            |
| `readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                                  | `5`             |
| `readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                                | `3`             |
| `readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                                | `1`             |
| `startupProbe.enabled`                  | Enable startupProbe on containers                                                                   | `false`         |
| `startupProbe.initialDelaySeconds`      | Initial delay seconds for startupProbe                                                              | `20`            |
| `startupProbe.periodSeconds`            | Period seconds for startupProbe                                                                     | `10`            |
| `startupProbe.timeoutSeconds`           | Timeout seconds for startupProbe                                                                    | `5`             |
| `startupProbe.failureThreshold`         | Failure threshold for startupProbe                                                                  | `3`             |
| `startupProbe.successThreshold`         | Success threshold for startupProbe                                                                  | `1`             |
| `customLivenessProbe`                   | Custom livenessProbe that overrides the default one                                                 | `{}`            |
| `customReadinessProbe`                  | Custom readinessProbe that overrides the default one                                                | `{}`            |
| `customStartupProbe`                    | Custom startupProbe that overrides the default one                                                  | `{}`            |
| `resources.limits`                      | The resources limits for the containers                                                             | `{}`            |
| `resources.requests`                    | The requested resources for the containers                                                          | `{}`            |
| `podSecurityContext.enabled`            | Enabled pods' Security Context                                                                      | `true`          |
| `podSecurityContext.fsGroup`            | Set pod's Security Context fsGroup                                                                  | `1001`          |
| `containerSecurityContext.enabled`      | Enabled containers' Security Context                                                                | `true`          |
| `containerSecurityContext.propogated`   | Propogate containerSecurityContext to all `podContainers` (when enabled==propogated==true)          | `true`          |
| `containerSecurityContext.runAsUser`    | Set containers' Security Context runAsUser                                                          | `1001`          |
| `containerSecurityContext.runAsNonRoot` | Set containers' Security Context runAsNonRoot                                                       | `true`          |
| `existingConfigmap`                     | The name of an existing ConfigMap with your custom configuration for                                | `nil`           |
| `command`                               | Override default container command (useful when using custom images)                                | `[]`            |
| `args`                                  | Override default container args (useful when using custom images)                                   | `[]`            |
| `hostAliases`                           | pods host aliases                                                                                   | `[]`            |
| `component`                             | Defines pod's component name (used for naming and labeling etc, not necessary for the default pod). | `""`            |
| `podLabels`                             | Extra labels for pods                                                                               | `{}`            |
| `podAnnotations`                        | Annotations for pods                                                                                | `{}`            |
| `podAffinityPreset`                     | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                 | `""`            |
| `podAntiAffinityPreset`                 | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`            | `soft`          |
| `nodeAffinityPreset.type`               | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`           | `""`            |
| `nodeAffinityPreset.key`                | Node label key to match. Ignored if `affinity` is set                                               | `""`            |
| `nodeAffinityPreset.values`             | Node label values to match. Ignored if `affinity` is set                                            | `[]`            |
| `affinity`                              | Affinity for pods assignment                                                                        | `{}`            |
| `nodeSelector`                          | Node labels for pods assignment                                                                     | `{}`            |
| `tolerations`                           | Tolerations for pods assignment                                                                     | `[]`            |
| `updateStrategy.type`                   | Deployment/Statefulset/Daemonset updateStrategy type                                                | `RollingUpdate` |
| `priorityClassName`                     | Pods' priorityClassName                                                                             | `""`            |
| `schedulerName`                         | Name of the k8s scheduler (other than default) for pods                                             | `""`            |
| `lifecycleHooks`                        | for the container(s) to automate configuration before or after startup                              | `{}`            |
| `env`                                   | Array with environment variables to add to nodes                                                    | `[]`            |
| `extraEnv`                              | Array with extra environment variables to add to nodes                                              | `[]`            |
| `envFromCMs`                            | Array of existing ConfigMap names containing env vars                                               | `[]`            |
| `envFromSecrets`                        | Array of existing Secret names containing env vars                                                  | `[]`            |
| `volumes`                               | Array of volumes for the pod(s)                                                                     | `[]`            |
| `extraVolumes`                          | Optionally specify extra list of additional volumes for the pod(s)                                  | `[]`            |
| `volumeMounts`                          | Array of volumeMounts for the pod(s) main container                                                 | `[]`            |
| `extraVolumeMounts`                     | Optionally specify extra mount list for the pod(s) main container                                   | `[]`            |
| `podContainers`                         | Pod containers, creates a multi-container pod(s) (`base.container` template is used)                | `[]`            |
| `sidecars`                              | Add additional sidecar containers to the pod(s) (raw definitions)                                   | `[]`            |
| `initContainers`                        | Add additional init containers to the pod(s)                                                        | `{}`            |
| `persistence.enabled`                   | Enable persistence, i.e. provide a volume for the default Pod                                       | `false`         |
| `persistence.volumeName`                | Specifies volume name for the default volume                                                        | `data`          |
| `persistence.storageClass`              | Specify a storageClassName                                                                          | `""`            |
| `persistence.existingClam`              | Specify an existing Persistent Volume Claim name                                                    | `""`            |
| `persistence.accessMode`                | Volume access mode                                                                                  | `ReadWriteOnce` |
| `persistence.size`                      | Volume size                                                                                         | `10Gi`          |
| `persistence.mountPath`                 | Volume mount path                                                                                   | `/data`         |


