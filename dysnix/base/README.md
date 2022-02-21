# Base

[base](https://github.com/dysnix/charts/tree/main/dysnix/base) is a library Helm chart. It aims to provide a value interface for resources generation from dependent charts.

## Create a dependant chart

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
    version: 0.3.x
    repository: https://dysnix.github.io/charts
    tags:
      - dysnix-base
EHD

cat <<EHD > $CHART_NAME/templates/all.yaml
{{/* vim: set filetype=mustache: */}}
{{- include "base.component.default" $ -}}
EHD
```

## Introduction

This chart provides library templates which are meant to deploy various number of [Kubernetes](http://kubernetes.io) resources using the [Helm](https://helm.sh) package manager. *Base* provides a rich set of templates to generate a component or multiple components along with the desired resources.

Unlike [bitnami chart template](https://github.com/bitnami/charts/tree/master/template) which is used for charts generation and their further modification, *base* encourages "use values first" approach. So *base* chart is used as a library chart with its templates providing comprehensive resource generation facilities such to get Deployment(s), Service(s) etc up and running. This can be achieved simply by modifying [values.yaml](values.yaml) file first. At the same time dependant charts might add, customize its own values and resources as needed.

*base* chart has **a concept of component** which represents a set of chart resources grouped by the same component name. Resources such as Deployment, ServiceAccount, PersistentVolumeClaim are groupped together by mixing *"common component"* part into its' names, resources of non-default component also shipped with the additional label set - `app.kubernetes.io/component: component_name`.

## Prerequisites

- Kubernetes 1.18+
- Helm 3.5.0

## Usage

To generate the default component resources use:

```go
{{- include "base.component.default" $ -}}
```

additional components can be generated using:

```go
{{- include "base.component" (dict "value" .Values.componentX "component" "componentx" "context" $) -}}
```

Again there's posibility to use resource template such as `base.service` or `base.deployment` directly in dependant charts.

## Chart configuration

The [Parameters](#parameters) section provides a full set of configuration parameters which define the bahaviour for dependant charts. Modify values.yaml to define resources configuration logic specific for the chart being developed.

### Service configuration

Configuration of a service has two forms: **map** and **list**. Map is a simplified form, works only for TCP ports and ports where targetPort matches the containerPort.

```yaml
containerPorts:
  rest: 8080

# Only relevant for ports specified in the map form
nodePorts:
  grpc: 30100

service:
  type: NodePort
  ports:
    http: rest
    grpc: 443
```

The above will create as a NodePort service (http goes to 8080, grpc to 443). Note that target port (such as *rest* in the above example) is looked up in `.containerPorts`, `.podContainers.*.ports` and `.sidecar.*.ports`.

Use list form to have more precise control over the ports configuration:

```yaml
containerPorts:
  rest: 8080

service:
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: rest
      nodePort: 30100
```

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
| `extraDeploy`       | Array of extra objects to deploy with the release                                            | `[]`            |


### Default Component default parameters

| Name                          | Description                                  | Value        |
| ----------------------------- | -------------------------------------------- | ------------ |
| `defaultComponent.enabled`    | Create the default Pod                       | `true`       |
| `defaultComponent.controller` | Default Pod controller type (case-sensetive) | `Deployment` |


### Component specific parameters

| Name                                    | Description                                                                                                                      | Value                    |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `image.registry`                        | Image registry                                                                                                                   | `""`                     |
| `image.repository`                      | Image name                                                                                                                       | `foo/bar`                |
| `image.tag`                             | Image tag                                                                                                                        | `latest`                 |
| `image.pullPolicy`                      | Image pull policy                                                                                                                | `""`                     |
| `image.pullSecrets`                     | Image pull secrets                                                                                                               | `[]`                     |
| `replicaCount`                          | Number of pod replicas to deploy                                                                                                 | `1`                      |
| `containerPorts`                        | Container Ports definition (dict form is also supported)                                                                         | `[]`                     |
| `livenessProbe.enabled`                 | Enable livenessProbe on containers                                                                                               | `false`                  |
| `livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                                                                          | `20`                     |
| `livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                                                                 | `10`                     |
| `livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                                                                | `5`                      |
| `livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                                                              | `3`                      |
| `livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                                                              | `1`                      |
| `readinessProbe.enabled`                | Enable readinessProbe on containers                                                                                              | `false`                  |
| `readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                                                                         | `20`                     |
| `readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                                                                | `10`                     |
| `readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                                                               | `5`                      |
| `readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                                                             | `3`                      |
| `readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                                                             | `1`                      |
| `startupProbe.enabled`                  | Enable startupProbe on containers                                                                                                | `false`                  |
| `startupProbe.initialDelaySeconds`      | Initial delay seconds for startupProbe                                                                                           | `20`                     |
| `startupProbe.periodSeconds`            | Period seconds for startupProbe                                                                                                  | `10`                     |
| `startupProbe.timeoutSeconds`           | Timeout seconds for startupProbe                                                                                                 | `5`                      |
| `startupProbe.failureThreshold`         | Failure threshold for startupProbe                                                                                               | `3`                      |
| `startupProbe.successThreshold`         | Success threshold for startupProbe                                                                                               | `1`                      |
| `customLivenessProbe`                   | Custom livenessProbe that overrides the default one                                                                              | `{}`                     |
| `customReadinessProbe`                  | Custom readinessProbe that overrides the default one                                                                             | `{}`                     |
| `customStartupProbe`                    | Custom startupProbe that overrides the default one                                                                               | `{}`                     |
| `resources.limits`                      | The resources limits for the containers                                                                                          | `{}`                     |
| `resources.requests`                    | The requested resources for the containers                                                                                       | `{}`                     |
| `podSecurityContext.enabled`            | Enabled pods' Security Context                                                                                                   | `true`                   |
| `podSecurityContext.fsGroup`            | Set pod's Security Context fsGroup                                                                                               | `1001`                   |
| `containerSecurityContext.enabled`      | Enabled containers' Security Context                                                                                             | `true`                   |
| `containerSecurityContext.propogated`   | Propogate containerSecurityContext to all containers `podContainers` (when enabled==propogated==true)                            | `true`                   |
| `containerSecurityContext.runAsUser`    | Set containers' Security Context runAsUser                                                                                       | `1001`                   |
| `containerSecurityContext.runAsNonRoot` | Set containers' Security Context runAsNonRoot                                                                                    | `true`                   |
| `command`                               | Override default container command (useful when using custom images)                                                             | `[]`                     |
| `args`                                  | Override default container args (useful when using custom images)                                                                | `[]`                     |
| `hostAliases`                           | pods host aliases                                                                                                                | `[]`                     |
| `component`                             | Defines pod's component name (used for naming and labeling etc, not necessary for the default pod).                              | `""`                     |
| `podLabels`                             | Extra labels for pods                                                                                                            | `{}`                     |
| `podAnnotations`                        | Annotations for pods                                                                                                             | `{}`                     |
| `podAffinityPreset`                     | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                              | `""`                     |
| `podAntiAffinityPreset`                 | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                         | `soft`                   |
| `nodeAffinityPreset.type`               | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                        | `""`                     |
| `nodeAffinityPreset.key`                | Node label key to match. Ignored if `affinity` is set                                                                            | `""`                     |
| `nodeAffinityPreset.values`             | Node label values to match. Ignored if `affinity` is set                                                                         | `[]`                     |
| `affinity`                              | Affinity for pods assignment                                                                                                     | `{}`                     |
| `nodeSelector`                          | Node labels for pods assignment                                                                                                  | `{}`                     |
| `tolerations`                           | Tolerations for pods assignment                                                                                                  | `[]`                     |
| `updateStrategy.type`                   | Deployment/Statefulset/Daemonset updateStrategy type                                                                             | `RollingUpdate`          |
| `priorityClassName`                     | Pods' priorityClassName                                                                                                          | `""`                     |
| `schedulerName`                         | Name of the k8s scheduler (other than default) for pods                                                                          | `""`                     |
| `lifecycleHooks`                        | for the container(s) to automate configuration before or after startup                                                           | `{}`                     |
| `env`                                   | Array with environment variables to add to nodes                                                                                 | `[]`                     |
| `extraEnv`                              | Array with extra environment variables to add to nodes                                                                           | `[]`                     |
| `envFromCMs`                            | Array of existing ConfigMap names containing env vars                                                                            | `[]`                     |
| `envFromSecrets`                        | Array of existing Secret names containing env vars                                                                               | `[]`                     |
| `volumes`                               | Array of volumes for the pod(s)                                                                                                  | `[]`                     |
| `extraVolumes`                          | Optionally specify extra list of additional volumes for the pod(s)                                                               | `[]`                     |
| `volumeMounts`                          | Array of volumeMounts for the pod(s) main container                                                                              | `[]`                     |
| `extraVolumeMounts`                     | Optionally specify extra mount list for the pod(s) main container                                                                | `[]`                     |
| `podContainers`                         | Pod containers, creates a multi-container pod(s) (`base.container` template is used)                                             | `[]`                     |
| `sidecars`                              | Add additional sidecar containers to the pod(s) (raw definitions)                                                                | `[]`                     |
| `initContainers`                        | Add additional init containers to the pod(s)                                                                                     | `{}`                     |
| `matchLabels`                           | Specifies additional matchLabels labels both for the controller metadata and the service                                         | `{}`                     |
| `autoscaling.enabled`                   | Specifies whether to enable HorizontalPodAutoscaler                                                                              | `false`                  |
| `autoscaling.minReplicas`               | Specifies the minimum amount of replicas                                                                                         | `1`                      |
| `autoscaling.maxReplicas`               | Specifies the maximum amount of replicas                                                                                         | `10`                     |
| `autoscaling.targetCPU`                 | Specifies the target average CPU utilization                                                                                     | `60`                     |
| `autoscaling.targetMemory`              | Specifies the target average Memory utilization                                                                                  | `60`                     |
| `autoscaling.metrics`                   | Specifies a custom list of metrics                                                                                               | `[]`                     |
| `serviceAccount.create`                 | Specifies whether a ServiceAccount should be created                                                                             | `true`                   |
| `serviceAccount.annotations`            | Annotations for the ServiceAccount                                                                                               | `{}`                     |
| `serviceAccount.name`                   | The name of the ServiceAccount to use.                                                                                           | `""`                     |
| `configMap.create`                      | Specifies whether to enable the ConfigMap (defaults to true if not set)                                                          | `true`                   |
| `configMap.immutable`                   | Ensures that data stored in the ConfigMap cannot be updated                                                                      | `false`                  |
| `configMap.annotations`                 | Annotations for the configMap                                                                                                    | `{}`                     |
| `configMap.data`                        | Specifies data stored in the ConfigMap (must be provided to create the resource)                                                 | `{}`                     |
| `secret.create`                         | Specifies whether to enable the Secret (defaults to true if not set)                                                             | `true`                   |
| `secret.immutable`                      | Ensures that data stored in the Secret cannot be updated                                                                         | `false`                  |
| `secret.annotations`                    | Annotations for the secret                                                                                                       | `{}`                     |
| `secret.data`                           | Specifies data stored in the Secret (either .data or .strigData should be provided)                                              | `{}`                     |
| `secret.stringData`                     | Specifies stringData stored in the Secret                                                                                        | `{}`                     |
| `service.type`                          | Service type (default is not set, effectively ClusterIP)                                                                         | `""`                     |
| `service.ports`                         | Map or list of defining service ports                                                                                            | `{}`                     |
| `service.nodePorts`                     | Map of nodePorts (effictive with type NodePort or LoadBalancer)                                                                  | `{}`                     |
| `service.clusterIP`                     | Service Cluster IP                                                                                                               | `nil`                    |
| `service.loadBalancerIP`                | Service Load Balancer IP                                                                                                         | `nil`                    |
| `service.loadBalancerSourceRanges`      | Service Load Balancer sources                                                                                                    | `[]`                     |
| `service.externalTrafficPolicy`         | Service external traffic policy                                                                                                  | `Cluster`                |
| `service.annotations`                   | Additional custom annotations for service                                                                                        | `{}`                     |
| `service.extraPorts`                    | Extra ports to expose in service (normally used with the `sidecars` value)                                                       | `[]`                     |
| `ingress.enabled`                       | Enable ingress record generation for %%MAIN_CONTAINER_NAME%%                                                                     | `false`                  |
| `ingress.pathType`                      | Ingress path type                                                                                                                | `ImplementationSpecific` |
| `ingress.apiVersion`                    | Force Ingress API version (automatically detected if not set)                                                                    | `nil`                    |
| `ingress.hostname`                      | Default host for the ingress record                                                                                              | `domain.local`           |
| `ingress.serviceName`                   | Backend Service name (if not empty overrides the default backend)                                                                | `""`                     |
| `ingress.servicePort`                   | Backend Service port ingress directs requests to                                                                                 | `""`                     |
| `ingress.path`                          | Default path for the ingress record                                                                                              | `/`                      |
| `ingress.annotations`                   | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. | `{}`                     |
| `ingress.tls`                           | Enable TLS configuration for the host defined at `ingress.hostname` parameter                                                    | `false`                  |
| `ingress.selfSigned`                    | Create a TLS secret for this ingress record using self-signed certificates generated by Helm                                     | `false`                  |
| `ingress.extraHosts`                    | An array with additional hostname(s) to be covered with the ingress record                                                       | `[]`                     |
| `ingress.extraPaths`                    | An array with additional arbitrary paths that may need to be added to the ingress under the main host                            | `[]`                     |
| `ingress.extraTls`                      | TLS configuration for additional hostname(s) to be covered with this ingress record                                              | `[]`                     |
| `ingress.extraTlsHosts`                 | Extra TLS hostname(s) added alongside to the default hostname (shares the default secret)                                        | `[]`                     |
| `ingress.secrets`                       | Custom TLS certificates as secrets                                                                                               | `[]`                     |
| `persistence.enabled`                   | Enable persistence, i.e. provide a volume for the default Pod                                                                    | `false`                  |
| `persistence.volumeName`                | Specifies volume name for the default volume                                                                                     | `data`                   |
| `persistence.storageClass`              | Specify a storageClassName                                                                                                       | `""`                     |
| `persistence.existingClam`              | Specify an existing Persistent Volume Claim name                                                                                 | `""`                     |
| `persistence.accessMode`                | Volume access mode                                                                                                               | `ReadWriteOnce`          |
| `persistence.size`                      | Volume size                                                                                                                      | `10Gi`                   |
| `persistence.mountPath`                 | Volume mount path                                                                                                                | `/data`                  |
| `persistence.ephemeral.enabled`         | Specifies whether to persist data only during Pod's lifetime                                                                     | `false`                  |
| `persistence.ephemeral.type`            | Specifies type of the ephemeral volume                                                                                           | `emptyDir`               |


