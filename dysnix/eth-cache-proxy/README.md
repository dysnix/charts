# eth-cache-proxy

[eth-cache-proxy](https://github.com/dysnix/charts/tree/main/dysnix/eth-cache-proxy)

## Prerequisites

- Kubernetes 1.18+
- Helm 3.5.0

## Parameters

### Global parameters

| Name                      | Description                                              | Value |
| ------------------------- | -------------------------------------------------------- | ----- |
| `global.imageRegistry`    | Global Docker image registry                             | `""`  |
| `global.imagePullSecrets` | Global Docker registry secret names as an array          | `[]`  |
| `global.storageClass`     | Global StorageClass for Persistent Volume(s)             | `""`  |
| `global.redis.password`   | Global Redis&trade; password (overrides `auth.password`) | `""`  |


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

| Name                                    | Description                                                                                                                      | Value                                                |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| `image.registry`                        | Image registry                                                                                                                   | `""`                                                 |
| `image.repository`                      | Image name                                                                                                                       | `dysnix/eth-cache-proxy`                             |
| `image.tag`                             | Image tag                                                                                                                        | `latest`                                             |
| `image.pullPolicy`                      | Image pull policy                                                                                                                | `""`                                                 |
| `image.pullSecrets`                     | Image pull secrets                                                                                                               | `[]`                                                 |
| `replicaCount`                          | Number of pod replicas to deploy                                                                                                 | `1`                                                  |
| `containerPorts`                        | Container Ports definition (dict form is also supported)                                                                         | `[]`                                                 |
| `livenessProbe.enabled`                 | Enable livenessProbe on containers                                                                                               | `false`                                              |
| `livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                                                                          | `5`                                                  |
| `livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                                                                 | `5`                                                  |
| `livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                                                                | `5`                                                  |
| `livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                                                              | `3`                                                  |
| `livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                                                              | `1`                                                  |
| `livenessProbe.httpGet.path`            | Health-check endpoint                                                                                                            | `/healthz`                                           |
| `livenessProbe.httpGet.port`            | Health-check port                                                                                                                | `8091`                                               |
| `readinessProbe.enabled`                | Enable readinessProbe on containers                                                                                              | `false`                                              |
| `readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                                                                         | `""`                                                 |
| `readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                                                                | `5`                                                  |
| `readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                                                               | `5`                                                  |
| `readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                                                             | `5`                                                  |
| `readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                                                             | `1`                                                  |
| `readinessProbe.httpGet.path`           | Health-check endpoint                                                                                                            | `/readyz`                                            |
| `readinessProbe.httpGet.port`           | Health-check port                                                                                                                | `8091`                                               |
| `startupProbe.enabled`                  | Enable startupProbe on containers                                                                                                | `false`                                              |
| `customLivenessProbe`                   | Custom livenessProbe that overrides the default one                                                                              | `{}`                                                 |
| `customReadinessProbe`                  | Custom readinessProbe that overrides the default one                                                                             | `{}`                                                 |
| `customStartupProbe`                    | Custom startupProbe that overrides the default one                                                                               | `{}`                                                 |
| `resources.limits`                      | The resources limits for the containers                                                                                          | `1300m`                                              |
| `resources.requests`                    | The requested resources for the containers                                                                                       | `1000m`                                              |
| `podSecurityContext.enabled`            | Enabled pods' Security Context                                                                                                   | `true`                                               |
| `podSecurityContext.fsGroup`            | Set pod's Security Context fsGroup                                                                                               | `1001`                                               |
| `containerSecurityContext.enabled`      | Enabled containers' Security Context                                                                                             | `true`                                               |
| `containerSecurityContext.propogated`   | Propogate containerSecurityContext to all containers `podContainers` (when enabled==propogated==true)                            | `true`                                               |
| `containerSecurityContext.runAsUser`    | Set containers' Security Context runAsUser                                                                                       | `1001`                                               |
| `containerSecurityContext.runAsNonRoot` | Set containers' Security Context runAsNonRoot                                                                                    | `true`                                               |
| `command`                               | Override default container command (useful when using custom images)                                                             | `["/app"]`                                           |
| `args`                                  | Override default container args (useful when using custom images)                                                                | `["-conf=/etc/eth-cache-proxy/configs/config.yaml"]` |
| `hostAliases`                           | pods host aliases                                                                                                                | `[]`                                                 |
| `component`                             | Defines pod's component name (used for naming and labeling etc, not necessary for the default pod).                              | `""`                                                 |
| `podLabels`                             | Extra labels for pods                                                                                                            | `{}`                                                 |
| `podAnnotations`                        | Annotations for pods                                                                                                             | `undefined`                                          |
| `podAffinityPreset`                     | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                              | `""`                                                 |
| `podAntiAffinityPreset`                 | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                         | `soft`                                               |
| `nodeAffinityPreset.type`               | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                        | `""`                                                 |
| `nodeAffinityPreset.key`                | Node label key to match. Ignored if `affinity` is set                                                                            | `""`                                                 |
| `nodeAffinityPreset.values`             | Node label values to match. Ignored if `affinity` is set                                                                         | `[]`                                                 |
| `affinity`                              | Affinity for pods assignment                                                                                                     | `{}`                                                 |
| `nodeSelector`                          | Node labels for pods assignment                                                                                                  | `{}`                                                 |
| `tolerations`                           | Tolerations for pods assignment                                                                                                  | `[]`                                                 |
| `updateStrategy.type`                   | Deployment/Statefulset/Daemonset updateStrategy type                                                                             | `RollingUpdate`                                      |
| `priorityClassName`                     | Pods' priorityClassName                                                                                                          | `""`                                                 |
| `schedulerName`                         | Name of the k8s scheduler (other than default) for pods                                                                          | `""`                                                 |
| `lifecycleHooks`                        | for the container(s) to automate configuration before or after startup                                                           | `{}`                                                 |
| `env`                                   | Array with environment variables to add to nodes                                                                                 | `nil`                                                |
| `extraEnv`                              | Array with extra environment variables to add to nodes                                                                           | `[]`                                                 |
| `envFromCMs`                            | Array of existing ConfigMap names containing env vars                                                                            | `[]`                                                 |
| `envFromSecrets`                        | Array of existing Secret names containing env vars                                                                               | `[]`                                                 |
| `volumes`                               | Array of volumes for the pod(s)                                                                                                  | `configs`                                            |
| `extraVolumes`                          | Optionally specify extra list of additional volumes for the pod(s)                                                               | `[]`                                                 |
| `volumeMounts`                          | Array of volumeMounts for the pod(s) main container                                                                              | `configs`                                            |
| `extraVolumeMounts`                     | Optionally specify extra mount list for the pod(s) main container                                                                | `[]`                                                 |
| `podContainers`                         | Pod containers, creates a multi-container pod(s) (`base.container` template is used)                                             | `[]`                                                 |
| `sidecars`                              | Add additional sidecar containers to the pod(s) (raw definitions)                                                                | `[]`                                                 |
| `initContainers`                        | Add additional init containers to the pod(s)                                                                                     | `{{- include "eth-cache-proxy.waitForRedis" . }}`    |
| `serviceAccount.create`                 | Specifies whether a ServiceAccount should be created                                                                             | `true`                                               |
| `serviceAccount.annotations`            | Annotations for the ServiceAccount                                                                                               | `{}`                                                 |
| `serviceAccount.name`                   | The name of the ServiceAccount to use.                                                                                           | `""`                                                 |
| `config`                                | Configuration of rpc-cache-proxy                                                                                                 | `{}`                                                 |
| `config.redis.readAddrs`                | Specifies redis read addresses list (comma separated)                                                                            | `""`                                                 |
| `config.redis.writeAddrs`               | Specifies redis write addresses list (comma separated)                                                                           | `""`                                                 |
| `config.redis.password`                 | Specifies rpc-cache-proxy password for Redis&trade;                                                                              | `""`                                                 |
| `configMap.create`                      | Specifies whether to enable the ConfigMap (defaults to true if not set)                                                          | `true`                                               |
| `configMap.immutable`                   | Ensures that data stored in the ConfigMap cannot be updated                                                                      | `false`                                              |
| `configMap.annotations`                 | Annotations for the configMap                                                                                                    | `{}`                                                 |
| `configMap.data`                        | Specifies data stored in the ConfigMap (must be provided to create the resource)                                                 | `{}`                                                 |
| `secret.create`                         | Specifies whether to enable the Secret (defaults to true if not set)                                                             | `true`                                               |
| `secret.immutable`                      | Ensures that data stored in the Secret cannot be updated                                                                         | `false`                                              |
| `secret.annotations`                    | Annotations for the secret                                                                                                       | `{}`                                                 |
| `secret.data`                           | Specifies data stored in the Secret (either .data or .strigData should be provided)                                              | `{}`                                                 |
| `secret.stringData`                     | Specifies stringData stored in the Secret                                                                                        | `{}`                                                 |
| `persistence.enabled`                   | Enable persistence, i.e. provide a volume for the default Pod                                                                    | `false`                                              |
| `persistence.volumeName`                | Specifies volume name for the default volume                                                                                     | `data`                                               |
| `persistence.storageClass`              | Specify a storageClassName                                                                                                       | `""`                                                 |
| `persistence.existingClam`              | Specify an existing Persistent Volume Claim name                                                                                 | `""`                                                 |
| `persistence.accessMode`                | Volume access mode                                                                                                               | `ReadWriteOnce`                                      |
| `persistence.size`                      | Volume size                                                                                                                      | `10Gi`                                               |
| `persistence.mountPath`                 | Volume mount path                                                                                                                | `/data`                                              |
| `service.type`                          | Service type (default is not set, effectively ClusterIP)                                                                         | `""`                                                 |
| `service.ports`                         | Map or list of defining service ports                                                                                            | `http`                                               |
| `service.nodePorts`                     | Map of nodePorts (effictive with type NodePort or LoadBalancer)                                                                  | `{}`                                                 |
| `service.clusterIP`                     | Service Cluster IP                                                                                                               | `nil`                                                |
| `service.loadBalancerIP`                | Service Load Balancer IP                                                                                                         | `nil`                                                |
| `service.loadBalancerSourceRanges`      | Service Load Balancer sources                                                                                                    | `[]`                                                 |
| `service.externalTrafficPolicy`         | Service external traffic policy                                                                                                  | `Cluster`                                            |
| `service.annotations`                   | Additional custom annotations for service                                                                                        | `{}`                                                 |
| `service.extraPorts`                    | Extra ports to expose in service (normally used with the `sidecars` value)                                                       | `[]`                                                 |
| `redis.enabled`                         | Enables bitnami redis deployment                                                                                                 | `false`                                              |
| `redis.auth.enabled`                    | Enable password authentication                                                                                                   | `true`                                               |
| `redis.auth.password`                   | Redis&trade; password                                                                                                            | `""`                                                 |
| `monitoring.enabled`                    |                                                                                                                                  | `false`                                              |
| `autoscaling.enabled`                   | Enables HPA                                                                                                                      | `false`                                              |
| `cacheType`                             | Defines eth cacher storage type                                                                                                  | `olric`                                              |
| `ingress.enabled`                       | Enable ingress record generation                                                                                                 | `false`                                              |
| `ingress.pathType`                      | Ingress path type                                                                                                                | `ImplementationSpecific`                             |
| `ingress.apiVersion`                    | Force Ingress API version (automatically detected if not set)                                                                    | `nil`                                                |
| `ingress.hostname`                      | Default host for the ingress record                                                                                              | `domain.local`                                       |
| `ingress.serviceName`                   | Backend Service name (if not empty overrides the default backend)                                                                | `""`                                                 |
| `ingress.servicePort`                   | Backend Service port ingress directs requests to                                                                                 | `http`                                               |
| `ingress.path`                          | Default path for the ingress record                                                                                              | `/`                                                  |
| `ingress.annotations`                   | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. | `{}`                                                 |
| `ingress.tls`                           | Enable TLS configuration for the host defined at `ingress.hostname` parameter                                                    | `false`                                              |
| `ingress.selfSigned`                    | Create a TLS secret for this ingress record using self-signed certificates generated by Helm                                     | `false`                                              |
| `ingress.extraHosts`                    | An array with additional hostname(s) to be covered with the ingress record                                                       | `[]`                                                 |
| `ingress.extraPaths`                    | An array with additional arbitrary paths that may need to be added to the ingress under the main host                            | `[]`                                                 |
| `ingress.extraTls`                      | TLS configuration for additional hostname(s) to be covered with this ingress record                                              | `[]`                                                 |
| `ingress.extraTlsHosts`                 | Extra TLS hostname(s) added alongside to the default hostname (shares the default secret)                                        | `[]`                                                 |
| `ingress.secrets`                       | Custom TLS certificates as secrets                                                                                               | `[]`                                                 |


