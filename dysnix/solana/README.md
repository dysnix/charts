# Solana helm chart

A Helm chart to deploy Solana node inside Kubernetes cluster.

## Parameters

### Global parameters

| Name                                        | Description                                             | Value                          |
| ------------------------------------------- | ------------------------------------------------------- | ------------------------------ |
| `replicaCount`                              | Number of pods to deploy in the Stateful Set            | `1`                            |
| `image.repository`                          | Solana image repository                                 | `ghcr.io/dysnix/docker-solana` |
| `image.tag`                                 | Solana image tag                                        | `""`                           |
| `image.pullPolicy`                          | Solana image pull policy                                | `IfNotPresent`                 |
| `imagePullSecrets`                          | Solana image pull secrets                               | `[]`                           |
| `nameOverride`                              | String to partially override release name               | `""`                           |
| `fullnameOverride`                          | String to fully override release name                   | `""`                           |
| `serviceAccount.create`                     | Specifies whether a ServiceAccount should be created    | `true`                         |
| `serviceAccount.name`                       | The name of the ServiceAccount to use                   | `""`                           |
| `serviceAccount.automount`                  | Whether to auto mount the service account token         | `true`                         |
| `serviceAccount.annotations`                | Additional custom annotations for the ServiceAccount    | `{}`                           |
| `podLabels`                                 | Extra labels for pods                                   | `{}`                           |
| `podAnnotations`                            | Annotations for pods                                    | `{}`                           |
| `podSecurityContext`                        | Configure securityContext for entire pod                | `{}`                           |
| `securityContext`                           | Configure securityContext for Solana container          | `{}`                           |
| `resources`                                 | Set container requests and limits for CPU or memory     | `{}`                           |
| `livenessProbe`                             | Solana container livenessProbe                          | `{}`                           |
| `startupProbe`                              | Solana container startupProbe                           | `{}`                           |
| `readinessProbe`                            | Solana container readinessProbe                         | `{}`                           |
| `affinity`                                  | Affinity for pod assignment                             | `{}`                           |
| `nodeSelector`                              | Node labels for pod assignment                          | `{}`                           |
| `tolerations`                               | Tolerations for pod assignment                          | `[]`                           |
| `volumes`                                   | Pod extra volumes                                       | `[]`                           |
| `volumeMounts`                              | Container extra volumeMounts                            | `[]`                           |
| `services.rpc.enabled`                      | Enable Solana RPC service                               | `true`                         |
| `services.rpc.type`                         | Solana RPC service type                                 | `ClusterIP`                    |
| `services.rpc.port`                         | Solana RPC service port (+1 for websocket)              | `8899`                         |
| `services.rpc.publishNotReadyAddresses`     | Route trafic even when pod is not ready                 | `false`                        |
| `services.metrics.enabled`                  | Enable Solana metrics service                           | `false`                        |
| `services.metrics.type`                     | Solana metrics service type                             | `ClusterIP`                    |
| `services.metrics.port`                     | Solana metrics service port                             | `9122`                         |
| `services.metrics.publishNotReadyAddresses` | Route trafic even when pod is not ready                 | `true`                         |
| `ingress.http`                              | Ingress configuration for Solana RPC HTTP endpoint      | `{}`                           |
| `ingress.ws`                                | Ingress configuration for Solana RPC WebSocket endpoint | `{}`                           |
| `metrics.enabled`                           | Enable Solana node metrics collection                   | `false`                        |
| `metrics.target`                            | Where to push Solana metrics                            | `exporter`                     |
| `metrics.exporter`                          | influxdb-exporter configuration                         | `{}`                           |
| `metrics.serviceMonitor.enabled`            | Enable Prometheus ServiceMonitor                        | `false`                        |
| `metrics.influxdb.existingSecret.name`      | Name of secret containing InfluxDB credentials          | `solana-metrics-config`        |
| `metrics.influxdb.existingSecret.key`       | Key name inside the secret                              | `config`                       |

### Solana node configuration

| Name                                         | Description                                                        | Value                             |
| -------------------------------------------- | ------------------------------------------------------------------ | --------------------------------- |
| `solanaArgs`                                 | `solana-validator` arguments                                       | `{}`                              |
| `gracefulShutdown.timeout`                   | Seconds to wait for graceful shutdown                              | `120`                             |
| `gracefulShutdown.options`                   | `solana-validator exit` arguments                                  | `{}`                              |
| `gracefulShutdown.options.force`             | Do not wait for restart-window, useful for non-validators          |                                   |
| `gracefulShutdown.options.skip-health-check` | Skip health check before exit                                      |                                   |
| `gracefulShutdown.options.skip-health-check` | Skip check for a new snapshot before exit                          |                                   |
| `rustLog`                                    | Logging configuration                                              | `solana=info,solana_metrics=warn` |
| `identity.validatorKeypair`                  | Validator keypair string (required)                                | `""`                              |
| `identity.voteKeypair`                       | Vote keypair string (required only for validator)                  | `""`                              |
| `identity.existingSecret`                    | Use existing secret with keypairs instead of specifying them above | `""`                              |
| `identity.mountPath`                         | Keypair files mount path                                           | `/secrets`                        |

### Solana ledger db persistence config

| Name                                    | Description                     | Value                       |
| --------------------------------------- | ------------------------------- | --------------------------- |
| `persistence.ledger.type`               | Ledger persistence type         | `pvc`                       |
| `persistence.ledger.pvc.annotations`    | PVC volume annotations          | `{}`                        |
| `persistence.ledger.pvc.accessMode`     | PVC volume access mode          | `ReadWriteOnce`             |
| `persistence.ledger.pvc.storageClass`   | PVC volume storage class name   | `""`                        |
| `persistence.ledger.pvc.size`           | PVC volume size                 | `2Ti`                       |
| `persistence.ledger.existingClaim.name` | Existing PVC configuration      | `solana-ledger-volume`      |
| `persistence.ledger.hostPath.type`      | hostPath volume type            | `Directory`                 |
| `persistence.ledger.hostPath.path`      | hostPath directory on host node | `/blockchain/solana-ledger` |

### Solana accounts db persistence config

| Name                                      | Description                     | Value                         |
| ----------------------------------------- | ------------------------------- | ----------------------------- |
| `persistence.accounts.type`               | Accounts persistence type       | `pvc`                         |
| `persistence.accounts.pvc.annotations`    | PVC volume annotations          | `{}`                          |
| `persistence.accounts.pvc.accessMode`     | PVC volume access mode          | `ReadWriteOnce`               |
| `persistence.accounts.pvc.storageClass`   | PVC volume storage class name   | `""`                          |
| `persistence.accounts.pvc.size`           | PVC volume size                 | `2Ti`                         |
| `persistence.accounts.existingClaim.name` | Existing PVC configuration      | `solana-accounts-volume`      |
| `persistence.accounts.hostPath.type`      | hostPath volume type            | `Directory`                   |
| `persistence.accounts.hostPath.path`      | hostPath directory on host node | `/blockchain/solana-accounts` |
