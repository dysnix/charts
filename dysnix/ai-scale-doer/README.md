# AI-Scale-Doer

[AI-Scale-Doer](https://github.com/dysnix/ai-scale-operator/Readme.md) is official ai-scale operator component 

## Introduction

This chart bootstraps a Deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.8+

## Installing the Chart
To install the chart with the release name `my-release`:

```console
$ helm repo add dysnix https://dysnix.github.io/charts
$ helm install my-release dysnix/ai-scale-doer
```

The command deploys AI-Scale-Doer on the Kubernetes cluster in the default configuration.
The [configuration](#configuration) section lists the parameters that can be configured during installation.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
helm install my-release -f values.yaml dysnix/ai-scale-doer
```

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release`:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

> **Tip**: You can use the default [values.yaml](values.yaml)

## Source Code

* <https://github.com/dysnix/charts>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | common | 1.10.x |
| https://dysnix.github.io/charts | base | 0.2.x |

## Persistence

AI-Scale-Doer is an AI-Scale operator microservice, which is used to manage k8s resources (scaling, etc.), 
interacts with the service Provider by communicating using the protobuf protocol.

## Configuration of service

For configuration service you can override list of options in [`configs`](https://github.com/dysnix/ai-scale-operator) values block.

## Parameters

The following tables lists the configurable parameters of the ***`ai-scale-doer`*** and ***`base`*** library chart and their default values.

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

| Name                          | Description                 | Value        |
| ----------------------------- | --------------------------- | ------------ |
| `defaultComponent.enabled`    | Create the default Pod      | `true`       |
| `defaultComponent.controller` | Default Pod controller type | `deployment` |


### Component specific parameters

| Name                                    | Description                                                                                                                      | Value                                                                                                                |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `image.registry`                        | Image registry                                                                                                                   | `""`                                                                                                                 |
| `image.repository`                      | Image name                                                                                                                       | `alex6021710/ai-scale-doer`                                                                                          |
| `image.tag`                             | Image tag                                                                                                                        | `latest`                                                                                                             |
| `image.pullPolicy`                      | Image pull policy                                                                                                                | `""`                                                                                                                 |
| `image.pullSecrets`                     | Image pull secrets                                                                                                               | `[]`                                                                                                                 |
| `replicaCount`                          | Number of pod replicas to deploy                                                                                                 | `1`                                                                                                                  |
| `containerPorts`                        | Container Ports definition (dict form is also supported)                                                                         | `[]`                                                                                                                 |
| `livenessProbe.enabled`                 | Enable livenessProbe on containers                                                                                               | `true`                                                                                                               |
| `livenessProbe.httpGet.path`            | Route for check liveness probes by HTTP                                                                                          | `/healthz`                                                                                                           |
| `livenessProbe.httpGet.port`            | Port for check liveness probes by HTTP                                                                                           | `8081`                                                                                                               |
| `livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                                                                          | `20`                                                                                                                 |
| `livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                                                                 | `10`                                                                                                                 |
| `livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                                                                | `5`                                                                                                                  |
| `livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                                                              | `3`                                                                                                                  |
| `livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                                                              | `1`                                                                                                                  |
| `readinessProbe.enabled`                | Enable readinessProbe on containers                                                                                              | `true`                                                                                                               |
| `readinessProbe.httpGet.path`           | Route for check readiness probes by HTTP                                                                                         | `/readyz`                                                                                                            |
| `readinessProbe.httpGet.port`           | Port for check readiness probes by HTTP                                                                                          | `8081`                                                                                                               |
| `readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                                                                         | `20`                                                                                                                 |
| `readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                                                                | `10`                                                                                                                 |
| `readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                                                               | `5`                                                                                                                  |
| `readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                                                             | `3`                                                                                                                  |
| `readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                                                             | `1`                                                                                                                  |
| `startupProbe.enabled`                  | Enable startupProbe on containers                                                                                                | `false`                                                                                                              |
| `startupProbe.initialDelaySeconds`      | Initial delay seconds for startupProbe                                                                                           | `20`                                                                                                                 |
| `startupProbe.periodSeconds`            | Period seconds for startupProbe                                                                                                  | `10`                                                                                                                 |
| `startupProbe.timeoutSeconds`           | Timeout seconds for startupProbe                                                                                                 | `5`                                                                                                                  |
| `startupProbe.failureThreshold`         | Failure threshold for startupProbe                                                                                               | `3`                                                                                                                  |
| `startupProbe.successThreshold`         | Success threshold for startupProbe                                                                                               | `1`                                                                                                                  |
| `customLivenessProbe`                   | Custom livenessProbe that overrides the default one                                                                              | `{}`                                                                                                                 |
| `customReadinessProbe`                  | Custom readinessProbe that overrides the default one                                                                             | `{}`                                                                                                                 |
| `customStartupProbe`                    | Custom startupProbe that overrides the default one                                                                               | `{}`                                                                                                                 |
| `resources.limits`                      | The resources limits for the containers                                                                                          | `{}`                                                                                                                 |
| `resources.requests`                    | The requested resources for the containers                                                                                       | `{}`                                                                                                                 |
| `podSecurityContext.enabled`            | Enabled pods' Security Context                                                                                                   | `true`                                                                                                               |
| `podSecurityContext.fsGroup`            | Set pod's Security Context fsGroup                                                                                               | `1001`                                                                                                               |
| `containerSecurityContext.enabled`      | Enabled containers' Security Context                                                                                             | `true`                                                                                                               |
| `containerSecurityContext.propogated`   | Propogate containerSecurityContext to all containers `podContainers` (when enabled==propogated==true)                            | `true`                                                                                                               |
| `containerSecurityContext.runAsUser`    | Set containers' Security Context runAsUser                                                                                       | `1001`                                                                                                               |
| `containerSecurityContext.runAsNonRoot` | Set containers' Security Context runAsNonRoot                                                                                    | `true`                                                                                                               |
| `command`                               | Override default container command (useful when using custom images)                                                             | `["/usr/local/bin/manager"]`                                                                                         |
| `args`                                  | Override default container args (useful when using custom images)                                                                | `{{- include "ai-doer.argsWebhooks" . }}`                                                                            |
| `overrideArgs`                          | Override default Doer service cmd args                                                                                           | `["--zap-log-level=debug"]`                                                                                          |
| `hostAliases`                           | pods host aliases                                                                                                                | `[]`                                                                                                                 |
| `component`                             | Defines pod's component name (used for naming and labeling etc, not necessary for the default pod).                              | `""`                                                                                                                 |
| `podLabels`                             | Extra labels for pods                                                                                                            | `{}`                                                                                                                 |
| `podAnnotations.checksum/config`        | Usage for upgrade chart from helmfile if service configs was override.                                                           | `{{ deepCopy .Values.configs | mergeOverwrite (.Files.Get "default-configs.yml" | fromYaml) | toYaml | sha256sum }}` |
| `podAffinityPreset`                     | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                              | `""`                                                                                                                 |
| `podAntiAffinityPreset`                 | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                         | `soft`                                                                                                               |
| `nodeAffinityPreset.type`               | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                        | `""`                                                                                                                 |
| `nodeAffinityPreset.key`                | Node label key to match. Ignored if `affinity` is set                                                                            | `""`                                                                                                                 |
| `nodeAffinityPreset.values`             | Node label values to match. Ignored if `affinity` is set                                                                         | `[]`                                                                                                                 |
| `affinity`                              | Affinity for pods assignment                                                                                                     | `{}`                                                                                                                 |
| `nodeSelector`                          | Node labels for pods assignment                                                                                                  | `{}`                                                                                                                 |
| `tolerations`                           | Tolerations for pods assignment                                                                                                  | `[]`                                                                                                                 |
| `updateStrategy.type`                   | Deployment/Statefulset/Daemonset updateStrategy type                                                                             | `RollingUpdate`                                                                                                      |
| `priorityClassName`                     | Pods' priorityClassName                                                                                                          | `""`                                                                                                                 |
| `schedulerName`                         | Name of the k8s scheduler (other than default) for pods                                                                          | `""`                                                                                                                 |
| `lifecycleHooks`                        | for the container(s) to automate configuration before or after startup                                                           | `{}`                                                                                                                 |
| `env`                                   | Array with environment variables to add to nodes                                                                                 | `[]`                                                                                                                 |
| `extraEnv`                              | Array with extra environment variables to add to nodes                                                                           | `[]`                                                                                                                 |
| `envFromCMs`                            | Array of existing ConfigMap names containing env vars                                                                            | `[]`                                                                                                                 |
| `envFromSecrets`                        | Array of existing Secret names containing env vars                                                                               | `[]`                                                                                                                 |
| `volumes`                               | Array of volumes for the pod(s)                                                                                                  | `{{- tpl (include "ai-doer.defaultVolumes" .) . | indent 0 }}`                                                       |
| `extraVolumes`                          | Optionally specify extra list of additional volumes for the pod(s)                                                               | `[]`                                                                                                                 |
| `volumeMounts`                          | Array of volumeMounts for the pod(s) main container                                                                              | `{{- tpl (include "ai-doer.defaultVolumeMounts" .) . | indent 0 }}`                                                  |
| `extraVolumeMounts`                     | Optionally specify extra mount list for the pod(s) main container                                                                | `[]`                                                                                                                 |
| `podContainers`                         | Pod containers, creates a multi-container pod(s) (`base.container` template is used)                                             | `[]`                                                                                                                 |
| `sidecars`                              | Add additional sidecar containers to the pod(s) (raw definitions)                                                                | `[]`                                                                                                                 |
| `initContainers`                        | Add additional init containers to the pod(s)                                                                                     | `{}`                                                                                                                 |
| `serviceAccount.create`                 | Specifies whether a ServiceAccount should be created                                                                             | `true`                                                                                                               |
| `serviceAccount.annotations`            | Annotations for the ServiceAccount                                                                                               | `{}`                                                                                                                 |
| `serviceAccount.name`                   | The name of the ServiceAccount to use.                                                                                           | `""`                                                                                                                 |
| `configs`                               | saver service configs override                                                                                                   | `{}`                                                                                                                 |
| `configMap.create`                      | Specifies whether to enable the ConfigMap (defaults to true if not set)                                                          | `true`                                                                                                               |
| `configMap.immutable`                   | Ensures that data stored in the ConfigMap cannot be updated                                                                      | `false`                                                                                                              |
| `configMap.annotations`                 | Annotations for the configMap                                                                                                    | `{}`                                                                                                                 |
| `configMap.data`                        | Specifies data stored in the ConfigMap (must be provided to create the resource)                                                 | `{}`                                                                                                                 |
| `secret.create`                         | Specifies whether to enable the Secret (defaults to true if not set)                                                             | `true`                                                                                                               |
| `secret.immutable`                      | Ensures that data stored in the Secret cannot be updated                                                                         | `false`                                                                                                              |
| `secret.annotations`                    | Annotations for the secret                                                                                                       | `{}`                                                                                                                 |
| `secret.data`                           | Specifies data stored in the Secret (either .data or .strigData should be provided)                                              | `{}`                                                                                                                 |
| `secret.stringData`                     | Specifies stringData stored in the Secret                                                                                        | `{}`                                                                                                                 |
| `persistence.enabled`                   | Enable persistence, i.e. provide a volume for the default Pod                                                                    | `false`                                                                                                              |
| `persistence.volumeName`                | Specifies volume name for the default volume                                                                                     | `data`                                                                                                               |
| `persistence.storageClass`              | Specify a storageClassName                                                                                                       | `""`                                                                                                                 |
| `persistence.existingClam`              | Specify an existing Persistent Volume Claim name                                                                                 | `""`                                                                                                                 |
| `persistence.accessMode`                | Volume access mode                                                                                                               | `ReadWriteOnce`                                                                                                      |
| `persistence.size`                      | Volume size                                                                                                                      | `10Gi`                                                                                                               |
| `persistence.mountPath`                 | Volume mount path                                                                                                                | `/data`                                                                                                              |
| `service.type`                          | Service type (default is not set, effectively ClusterIP)                                                                         | `""`                                                                                                                 |
| `service.ports`                         | Map or list of defining service ports                                                                                            | `{{- include "ai-doer.getServicePorts" . }}`                                                                         |
| `service.overridePorts`                 | Map or list of defining service ports will merged to ports slice                                                                 | `[]`                                                                                                                 |
| `service.nodePorts`                     | Map of nodePorts (effective with type NodePort or LoadBalancer)                                                                  | `{}`                                                                                                                 |
| `service.clusterIP`                     | Service Cluster IP                                                                                                               | `nil`                                                                                                                |
| `service.loadBalancerIP`                | Service Load Balancer IP                                                                                                         | `nil`                                                                                                                |
| `service.loadBalancerSourceRanges`      | Service Load Balancer sources                                                                                                    | `[]`                                                                                                                 |
| `service.externalTrafficPolicy`         | Service external traffic policy                                                                                                  | `Cluster`                                                                                                            |
| `service.annotations`                   | Additional custom annotations for service                                                                                        | `{}`                                                                                                                 |
| `service.extraPorts`                    | Extra ports to expose in service (normally used with the `sidecars` value)                                                       | `[]`                                                                                                                 |
| `ingress.enabled`                       | Enable ingress record generation for %%MAIN_CONTAINER_NAME%%                                                                     | `false`                                                                                                              |
| `ingress.pathType`                      | Ingress path type                                                                                                                | `ImplementationSpecific`                                                                                             |
| `ingress.apiVersion`                    | Force Ingress API version (automatically detected if not set)                                                                    | `nil`                                                                                                                |
| `ingress.hostname`                      | Default host for the ingress record                                                                                              | `domain.local`                                                                                                       |
| `ingress.serviceName`                   | Backend Service name (if not empty overrides the default backend)                                                                | `""`                                                                                                                 |
| `ingress.servicePort`                   | Backend Service port ingress directs requests to                                                                                 | `""`                                                                                                                 |
| `ingress.path`                          | Default path for the ingress record                                                                                              | `/`                                                                                                                  |
| `ingress.annotations`                   | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. | `{}`                                                                                                                 |
| `ingress.tls`                           | Enable TLS configuration for the host defined at `ingress.hostname` parameter                                                    | `false`                                                                                                              |
| `ingress.selfSigned`                    | Create a TLS secret for this ingress record using self-signed certificates generated by Helm                                     | `false`                                                                                                              |
| `ingress.extraHosts`                    | An array with additional hostname(s) to be covered with the ingress record                                                       | `[]`                                                                                                                 |
| `ingress.extraPaths`                    | An array with additional arbitrary paths that may need to be added to the ingress under the main host                            | `[]`                                                                                                                 |
| `ingress.extraTls`                      | TLS configuration for additional hostname(s) to be covered with this ingress record                                              | `[]`                                                                                                                 |
| `ingress.secrets`                       | Custom TLS certificates as secrets                                                                                               | `[]`                                                                                                                 |
| `monitoring.enabled`                    |                                                                                                                                  | `false`                                                                                                              |
| `rbac.enabled`                          |                                                                                                                                  | `true`                                                                                                               |
| `autoscaling.enabled`                   | Enable HPA resource usage                                                                                                        | `false`                                                                                                              |
| `webhook.enabled`                       | Enable operator usage webhook's                                                                                                  | `false`                                                                                                              |
| `webhook.tls.certDir`                   | Directory with mounted certificates for webhook's                                                                                | `/etc/webhooks/certs`                                                                                                |
| `webhook.certs.secretName`              | Name of secret with generated or load certificates                                                                               | `webhook-secret`                                                                                                     |
| `webhook.certs.generate`                | Enabled generate or not self signed certificates                                                                                 | `true`                                                                                                               |
| `webhook.certs.ca.crt`                  | CA certificate override                                                                                                          | `""`                                                                                                                 |
| `webhook.certs.server.tls.crt`          | CRT certificate override                                                                                                         | `""`                                                                                                                 |
| `webhook.certs.server.tls.key`          | KEY certificate override                                                                                                         | `""`                                                                                                                 |
| `crd.enabled`                           | Enable deploy CR list                                                                                                            | `false`                                                                                                              |
| `crd.crs`                               | CR list                                                                                                                          | `[]`                                                                                                                 |