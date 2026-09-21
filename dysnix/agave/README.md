# Agave helm chart

A Helm chart to deploy Agave node inside Kubernetes cluster.

## Parameters

### Global parameters

| Name                              | Description                                                                                          | Value                         |
| --------------------------------- | ---------------------------------------------------------------------------------------------------- | ----------------------------- |
| `image.repository`                | Agave image repository                                                                               | `ghcr.io/dysnix/docker-agave` |
| `image.tag`                       | Agave image tag                                                                                      | `""`                          |
| `image.pullPolicy`                | Agave image pull policy                                                                              | `IfNotPresent`                |
| `imagePullSecrets`                | Agave image pull secrets                                                                             | `[]`                          |
| `nameOverride`                    | String to partially override release name                                                            | `""`                          |
| `fullnameOverride`                | String to fully override release name                                                                | `""`                          |
| `serviceAccount.create`           | Specifies whether a ServiceAccount should be created                                                 | `true`                        |
| `serviceAccount.name`             | The name of the ServiceAccount to use                                                                | `""`                          |
| `serviceAccount.automount`        | Whether to auto mount the service account token                                                      | `true`                        |
| `serviceAccount.annotations`      | Additional custom annotations for the ServiceAccount                                                 | `{}`                          |
| `podLabels`                       | Extra labels for pods                                                                                | `{}`                          |
| `podAnnotations`                  | Annotations for pods                                                                                 | `{}`                          |
| `env`                             | Additional environment variables for the main Agave container; supports valueFrom and Helm templates | `[]`                          |
| `envFrom`                         | Secret or ConfigMap environment sources for the main Agave container; supports Helm templates        | `[]`                          |
| `extraContainerPorts`             | Additional ports to expose on Agave container                                                        | `[]`                          |
| `podSecurityContext`              | Configure securityContext for entire pod                                                             | `{}`                          |
| `securityContext`                 | Configure securityContext for Agave container                                                        | `{}`                          |
| `resources`                       | Set container requests and limits for CPU or memory                                                  | `{}`                          |
| `resizePolicy`                    | specifies container resize policies                                                                  | `{}`                          |
| `livenessProbe`                   | Agave container livenessProbe                                                                        | `{}`                          |
| `startupProbe`                    | Agave container startupProbe                                                                         | `{}`                          |
| `readinessProbe`                  | Agave container readinessProbe                                                                       | `{}`                          |
| `readinessProbeSlotDiffThreshold` | Agave node slot diff threshold for readinessProbe                                                    | `150`                         |
| `affinity`                        | Affinity for pod assignment                                                                          | `{}`                          |
| `nodeSelector`                    | Node labels for pod assignment                                                                       | `{}`                          |
| `tolerations`                     | Tolerations for pod assignment                                                                       | `[]`                          |
| `volumes`                         | Pod extra volumes                                                                                    | `[]`                          |
| `volumeMounts`                    | Container extra volumeMounts                                                                         | `[]`                          |
| `extraInitContainers`             | Extra initContainers (can be templated)                                                              | `[]`                          |
| `sidecarContainers`               | Extra sidecar containers (can be templated)                                                          | `[]`                          |

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

| Name                                               | Description                                                                                                      | Value                                                            |
| -------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| `agaveArgs`                                        | `agave-validator` arguments                                                                                      | `{}`                                                             |
| `adjustLimitMemLock.enabled`                       | Enable adjustment of memory lock limit for Agave container                                                       | `false`                                                          |
| `adjustLimitMemLock.limit`                         | Memory lock limit in kilobytes                                                                                   | `2000000000`                                                     |
| `sysctl.image.repository`                          | Repository for the sysctl container image                                                                        | `busybox`                                                        |
| `sysctl.image.tag`                                 | Tag for the sysctl container image                                                                               | `latest`                                                         |
| `sysctl.resources`                                 | Resources for the sysctl container                                                                               | `{}`                                                             |
| `gracefulShutdown.timeout`                         | Seconds to wait for graceful shutdown                                                                            | `120`                                                            |
| `gracefulShutdown.options`                         | `agave-validator exit` arguments                                                                                 | `{}`                                                             |
| `gracefulShutdown.options.force`                   | Do not wait for restart window, useful for non-validators                                                        | `false`                                                          |
| `gracefulShutdown.options.skip-health-check`       | Skip health check before exit                                                                                    | `false`                                                          |
| `gracefulShutdown.options.skip-new-snapshot-check` | Skip check for a new snapshot before exit                                                                        | `false`                                                          |
| `rustLog`                                          | Logging configuration                                                                                            | `solana_metrics=warn,agave_validator::bootstrap=debug,info`      |
| `plugins.enabled`                                  | Enable download of Geyser plugins                                                                                | `false`                                                          |
| `plugins.image.repository`                         | Image repository for the download-plugins container                                                              | `python`                                                         |
| `plugins.image.tag`                                | Image tag for the download-plugins container                                                                     | `3.13-alpine`                                                    |
| `plugins.resources`                                | Resources for the download-plugins container                                                                     | `{}`                                                             |
| `plugins.volumeMounts`                             | Additional mounts for download-plugins, referencing top-level volumes (e.g. read-only local plugin files)        | `[]`                                                             |
| `plugins.containerPorts`                           | Extra container ports for added plugins                                                                          | `[]`                                                             |
| `plugins.servicePorts`                             | Extra service ports for added plugins                                                                            | `[]`                                                             |
| `plugins.yellowstoneGRPC.enabled`                  | Enable download of Yellowstone gRPC                                                                              | `false`                                                          |
| `plugins.yellowstoneGRPC.version`                  | Yellowstone gRPC version                                                                                         | `v15.1.2+solana.4.2.0`                                           |
| `plugins.yellowstoneGRPC.downloadURL`              | Yellowstone GRPC plugin download URL                                                                             | `https://github.com/rpcpool/yellowstone-grpc/releases/download/` |
| `plugins.yellowstoneGRPC.github.repository`        | GitHub owner/repository; enables authenticated API downloads instead of downloadURL. Local files take precedence | `""`                                                             |
| `plugins.yellowstoneGRPC.github.tokenSecret.name`  | Existing Secret containing a GitHub token with Contents: read for this repository                                | `""`                                                             |
| `plugins.yellowstoneGRPC.github.tokenSecret.key`   | Token key in the existing Secret                                                                                 | `token`                                                          |
| `plugins.yellowstoneGRPC.localFile`                | Mounted plugin file path; takes precedence over remote sources                                                   | `""`                                                             |
| `plugins.yellowstoneGRPC.sha256`                   | Optional expected SHA256; matching installed files skip download/copy                                            | `""`                                                             |
| `plugins.yellowstoneGRPC.listenIP`                 | Yellowstone gRPC listen IP address, without port                                                                 | `$(MY_POD_IP)`                                                   |
| `plugins.yellowstoneGRPC.configYaml`               | Yellowstone gRPC config file                                                                                     | `look in values.yaml`                                            |
| `plugins.yellowstoneGRPC.config`                   | Yellowstone gRPC config.json file                                                                                | `""`                                                             |
| `identity.validatorKeypair`                        | Validator keypair string (required)                                                                              | `""`                                                             |
| `identity.voteKeypair`                             | Vote keypair string (required only for validator)                                                                | `""`                                                             |
| `identity.existingSecret`                          | Use existing secret with keypairs instead of specifying them above                                               | `""`                                                             |
| `identity.mountPath`                               | Keypair files mount path                                                                                         | `/secrets`                                                       |

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

For private releases, create a Secret in the workload namespace containing a
fine-grained GitHub token with **Contents: read** for the repository. Reference
that Secret; do not put the token in Helm values:

```yaml
plugins:
  enabled: true
  yellowstoneGRPC:
    enabled: true
    version: YOUR_INTERNAL_RELEASE_TAG
    github:
      repository: dysnix/yellowstone-grpc
      tokenSecret:
        name: yellowstone-github
        key: token
```

The release must contain `libyellowstone_grpc_geyser.so` and `SHA256SUMS` in
standard `sha256sum` format. The downloader authenticates GitHub API requests,
strips authorization on asset redirects, and verifies the binary before replacing
an existing library. Failed downloads or checksum mismatches leave it intact.

To use a prebuilt library from an existing PVC instead of downloading:

```yaml
volumes:
  - name: prebuilt-yellowstone
    persistentVolumeClaim:
      claimName: prebuilt-yellowstone
plugins:
  enabled: true
  volumeMounts:
    - name: prebuilt-yellowstone
      mountPath: /prebuilt
      readOnly: true
  yellowstoneGRPC:
    enabled: true
    localFile: /prebuilt/libyellowstone_grpc_geyser.so
```

A hostPath or another native volume source can be supplied in `volumes` as well.
Local mode needs no GitHub Secret, even when a repository is configured.

Caching hashes the **installed destination file**, without a separate cache
volume. An explicit `sha256` match skips all network requests/copying. Otherwise,
GitHub mode fetches release metadata and `SHA256SUMS`, skipping the binary when
its installed hash matches; local mode compares against the source file hash.
Public URL mode without an explicit checksum downloads each time. `/plugins`
remains an `emptyDir`: files survive initContainer retries, but not Pod deletion.
The mounted source PVC supplies prebuilt libraries; it is not a download cache.
