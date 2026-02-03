# Agave helm chart

A Helm chart to deploy Agave node inside Kubernetes cluster.

## Parameters

### Global parameters

| Name                              | Description                                          | Value                         |
| --------------------------------- | ---------------------------------------------------- | ----------------------------- |
| `image.repository`                | Agave image repository                               | `ghcr.io/dysnix/docker-agave` |
| `image.tag`                       | Agave image tag                                      | `""`                          |
| `image.pullPolicy`                | Agave image pull policy                              | `IfNotPresent`                |
| `imagePullSecrets`                | Agave image pull secrets                             | `[]`                          |
| `nameOverride`                    | String to partially override release name            | `""`                          |
| `fullnameOverride`                | String to fully override release name                | `""`                          |
| `serviceAccount.create`           | Specifies whether a ServiceAccount should be created | `true`                        |
| `serviceAccount.name`             | The name of the ServiceAccount to use                | `""`                          |
| `serviceAccount.automount`        | Whether to auto mount the service account token      | `true`                        |
| `serviceAccount.annotations`      | Additional custom annotations for the ServiceAccount | `{}`                          |
| `podLabels`                       | Extra labels for pods                                | `{}`                          |
| `podAnnotations`                  | Annotations for pods                                 | `{}`                          |
| `extraContainerPorts`             | Additional ports to expose on Agave container        | `[]`                          |
| `podSecurityContext`              | Configure securityContext for entire pod             | `{}`                          |
| `securityContext`                 | Configure securityContext for Agave container        | `{}`                          |
| `resources`                       | Set container requests and limits for CPU or memory  | `{}`                          |
| `livenessProbe`                   | Agave container livenessProbe                        | `{}`                          |
| `startupProbe`                    | Agave container startupProbe                         | `{}`                          |
| `readinessProbe`                  | Agave container readinessProbe                       | `{}`                          |
| `readinessProbeSlotDiffThreshold` | Agave node slot diff threshold for readinessProbe    | `150`                         |
| `affinity`                        | Affinity for pod assignment                          | `{}`                          |
| `nodeSelector`                    | Node labels for pod assignment                       | `{}`                          |
| `tolerations`                     | Tolerations for pod assignment                       | `[]`                          |
| `volumes`                         | Pod extra volumes                                    | `[]`                          |
| `volumeMounts`                    | Container extra volumeMounts                         | `[]`                          |
| `extraInitContainers`             | Extra initContainers (can be templated)              | `[]`                          |
| `sidecarContainers`               | Extra sidecar containers (can be templated)          | `[]`                          |

### Services configuration

| Name                                        | Description                                 | Value       |
| ------------------------------------------- | ------------------------------------------- | ----------- |
| `services.rpc.enabled`                      | Enable Agave RPC service                    | `true`      |
| `services.rpc.type`                         | Agave RPC service type                      | `ClusterIP` |
| `services.rpc.port`                         | Agave RPC service port (+1 for websocket)   | `8899`      |
| `services.rpc.extraPorts`                   | Agave RPC service extra ports to expose     | `[]`        |
| `services.rpc.publishNotReadyAddresses`     | Route trafic even when pod is not ready     | `false`     |
| `services.metrics.enabled`                  | Enable Agave metrics service                | `false`     |
| `services.metrics.type`                     | Agave metrics service type                  | `ClusterIP` |
| `services.metrics.port`                     | Agave metrics service port                  | `9122`      |
| `services.metrics.extraPorts`               | Agave metrics service extra ports to expose | `[]`        |
| `services.metrics.publishNotReadyAddresses` | Route trafic even when pod is not ready     | `true`      |

### Ingress configuration

| Name              | Description                                            | Value |
| ----------------- | ------------------------------------------------------ | ----- |
| `ingress.http`    | Ingress configuration for Agave RPC HTTP endpoint      | `{}`  |
| `ingress.ws`      | Ingress configuration for Agave RPC WebSocket endpoint | `{}`  |
| `ingress.plugins` | Ingress configuration for Agave plugins                | `{}`  |

### Metrics configuration

| Name                                      | Description                                                                           | Value                  |
| ----------------------------------------- | ------------------------------------------------------------------------------------- | ---------------------- |
| `metrics.enabled`                         | Enable Agave node metrics collection                                                  | `false`                |
| `metrics.target`                          | Where to push Agave metrics                                                           | `exporter`             |
| `metrics.exporter`                        | influxdb-exporter configuration                                                       | `{}`                   |
| `metrics.serviceMonitor.enabled`          | Enable Prometheus ServiceMonitor                                                      | `false`                |
| `metrics.prometheusRule.enabled`          | Create a custom prometheusRule Resource for scraping metrics using PrometheusOperator | `false`                |
| `metrics.prometheusRule.namespace`        | The namespace in which the prometheusRule will be created                             | `""`                   |
| `metrics.prometheusRule.additionalLabels` | Additional labels for the prometheusRule                                              | `{}`                   |
| `metrics.prometheusRule.rules`            | Prometheus rules                                                                      | `[]`                   |
| `metrics.influxdb.existingSecret.name`    | Name of secret containing InfluxDB credentials                                        | `agave-metrics-config` |
| `metrics.influxdb.existingSecret.key`     | Key name inside the secret                                                            | `config`               |
| `hostNetwork`                             | Enable hostNetwork for Agave container                                                | `true`                 |

### Agave node configuration

| Name                                               | Description                                                        | Value                                                                           |
| -------------------------------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------- |
| `agaveArgs`                                        | `agave-validator` arguments                                        | `{}`                                                                            |
| `adjustLimitMemLock.enabled`                       | Enable adjustment of memory lock limit for Agave container         | `false`                                                                         |
| `adjustLimitMemLock.limit`                         | Memory lock limit in kilobytes                                     | `2000000000`                                                                    |
| `gracefulShutdown.timeout`                         | Seconds to wait for graceful shutdown                              | `120`                                                                           |
| `gracefulShutdown.options`                         | `agave-validator exit` arguments                                   | `{}`                                                                            |
| `gracefulShutdown.options.force`                   | Do not wait for restart window, useful for non-validators          | `false`                                                                         |
| `gracefulShutdown.options.skip-health-check`       | Skip health check before exit                                      | `false`                                                                         |
| `gracefulShutdown.options.skip-new-snapshot-check` | Skip check for a new snapshot before exit                          | `false`                                                                         |
| `rustLog`                                          | Logging configuration                                              | `solana_metrics=warn,agave_validator::bootstrap=debug,info`                     |
| `plugins.enabled`                                  | Enable download of Geyser plugins                                  | `false`                                                                         |
| `plugins.containerPorts`                           | Extra container ports for added plugins                            | `[]`                                                                            |
| `plugins.servicePorts`                             | Extra service ports for added plugins                              | `[]`                                                                            |
| `plugins.yellowstoneGRPC.enabled`                  | Enable download of Yellowstone gRPC                                | `false`                                                                         |
| `plugins.yellowstoneGRPC.version`                  | Yellowstone gRPC version                                           | `v11.0.1+solana.3.1.8`                                                          |
| `plugins.yellowstoneGRPC.downloadURL`              | Yellowstone GRPC plugin download URL                               | `https://github.com/rpcpool/yellowstone-grpc/releases/download/`                |
| `plugins.yellowstoneGRPC.listenIP`                 | Yellowstone gRPC listen IP address, without port                   | `$(MY_POD_IP)`                                                                  |
| `plugins.yellowstoneGRPC.configYaml`               | Yellowstone gRPC config file                                       | `look in values.yaml`                                                           |
| `plugins.yellowstoneGRPC.config`                   | Yellowstone gRPC config.json file                                  | `""`                                                                            |
| `plugins.richat.enabled`                           | Enable download of Richat                                          | `false`                                                                         |
| `plugins.richat.downloadURL`                       | Richat download URL                                                | `https://pub-f70d2191aa5a466faa56be3f4d80638a.r2.dev/librichat_plugin_agave.so` |
| `plugins.richat.listenIP`                          | Richat listen IP address, without port                             | `$(MY_POD_IP)`                                                                  |
| `plugins.richat.configYaml`                        | Richat config file                                                 | `look in values.yaml`                                                           |
| `plugins.richat.config`                            | Richat config.json file                                            | `""`                                                                            |
| `identity.validatorKeypair`                        | Validator keypair string (required)                                | `""`                                                                            |
| `identity.voteKeypair`                             | Vote keypair string (required only for validator)                  | `""`                                                                            |
| `identity.existingSecret`                          | Use existing secret with keypairs instead of specifying them above | `""`                                                                            |
| `identity.mountPath`                               | Keypair files mount path                                           | `/secrets`                                                                      |

### Agave ledger db persistence config

| Name                                    | Description                     | Value                      |
| --------------------------------------- | ------------------------------- | -------------------------- |
| `persistence.ledger.type`               | Ledger persistence type         | `pvc`                      |
| `persistence.ledger.pvc.annotations`    | PVC volume annotations          | `{}`                       |
| `persistence.ledger.pvc.accessMode`     | PVC volume access mode          | `ReadWriteOnce`            |
| `persistence.ledger.pvc.storageClass`   | PVC volume storage class name   | `""`                       |
| `persistence.ledger.pvc.size`           | PVC volume size                 | `2Ti`                      |
| `persistence.ledger.existingClaim.name` | Existing PVC configuration      | `agave-ledger-volume`      |
| `persistence.ledger.hostPath.type`      | hostPath volume type            | `Directory`                |
| `persistence.ledger.hostPath.path`      | hostPath directory on host node | `/blockchain/agave-ledger` |

### Agave accounts db persistence config

| Name                                      | Description                     | Value                        |
| ----------------------------------------- | ------------------------------- | ---------------------------- |
| `persistence.accounts.type`               | Accounts persistence type       | `pvc`                        |
| `persistence.accounts.pvc.annotations`    | PVC volume annotations          | `{}`                         |
| `persistence.accounts.pvc.accessMode`     | PVC volume access mode          | `ReadWriteOnce`              |
| `persistence.accounts.pvc.storageClass`   | PVC volume storage class name   | `""`                         |
| `persistence.accounts.pvc.size`           | PVC volume size                 | `2Ti`                        |
| `persistence.accounts.existingClaim.name` | Existing PVC configuration      | `agave-accounts-volume`      |
| `persistence.accounts.hostPath.type`      | hostPath volume type            | `Directory`                  |
| `persistence.accounts.hostPath.path`      | hostPath directory on host node | `/blockchain/agave-accounts` |
| `persistence.accounts.emptyDir.medium`    | emptyDir volume medium          | `""`                         |
| `persistence.accounts.emptyDir.sizeLimit` | emptyDir volume size limit      | `""`                         |
