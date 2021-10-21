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

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release`:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the ***`ai-scale-doer`*** and ***`base`*** library chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| args | list | `[]` |  |
| autoscaling.enabled | bool | `true` |  |
| autoscaling.maxReplicas | int | `10` |  |
| autoscaling.minReplicas | int | `1` |  |
| checksums | list | `[]` |  |
| command | list | `["/manager"]` |  |
| args | list | `["--leader-elect=false","--sync-period=120s","--conf=/etc/doer/configs/configs.yaml","--health-probe-bind-address=:8081","--metrics-bind-address=:8091","--disable-webhooks=true","--tls-cert-dir=/etc/webhooks/certs","--webhooks-port=443"]` |  |
| commonAnnotations | object | `{}` |  |
| commonLabels | object | `{"control-plane":"controller-manager","controller-tools.k8s.io":"1.0","app.kubernetes.io/component":"operator"}` |  |
| commonSelectors | object | `{"control-plane":"controller-manager","controller-tools.k8s.io":"1.0","app.kubernetes.io/component":"operator"}` |  |
| configMaps | object | `{}` |  |
| configMaps.configs.data.configs.yaml | file | `{"debugMode":true,"profiling":{"enabled":true,"host":"localhost","port":6060},"startupWorkers":{"cron":"@every 20s"},"grpc":{"enabled":true,"useReflection":true,"compression":{"enabled":true,"type":"Zstd"},"connection":{"host":"localhost","port":8090,"readBufferSize":"100MiB","writeBufferSize":"100MiB","maxMessageSize":"30MiB","insecure":true,"timeout":"15s"}}}` |  |
| containerPorts | list | `[{"name":"https","containerPort":443,"protocol":"TCP"},{"name":"pprof","containerPort":6060,"protocol":"TCP"},{"name":"metrics","containerPort":8091,"protocol":"TCP"},{"name":"probes","containerPort":8081,"protocol":"TCP"}]` |  |
| containerSecurityContext.enabled | bool | `false` |  |
| containerSecurityContext.runAsUser | int | `1001` |  |
| crd.enabled | bool | `false` |  |
| crd.crs | list | `[]` |  |
| dnsPolicy | string | `"ClusterFirst"` |  |
| env | object | `{}` |  |
| envFrom | list | `[]` |  |
| hostAliases | list | `[]` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.registry | string | `""` |  |
| image.repository | string | `"alex6021710/ai-scale-doer"` |  |
| image.tag | string | `"latest"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.apiVersion | string | `nil` |  |
| ingress.certManager | bool | `false` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hostname | string | `"app.local"` |  |
| ingress.nginx.configurationSnippet | string | `nil` |  |
| ingress.nginx.serverSnippet | string | `nil` |  |
| ingress.path | string | `"/"` |  |
| ingress.pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | bool | `false` |  |
| initContainers | list | `[]` |  |
| kind | string | `"Deployment"` |  |
| livenessProbe.enabled | bool | `false` |  |
| livenessProbe.httpGet.path | string | `/healthz` |  |
| livenessProbe.httpGet.port | int | `8081` |  |
| livenessProbe.failureThreshold | int | `6` |  |
| livenessProbe.initialDelaySeconds | int | `60` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.successThreshold | int | `1` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| monitoring.enabled | bool | `false` |  |
| monitoring.port | int | `8091` |  |
| name | string | `nil` |  |
| nodeAffinityPreset.key | string | `""` |  |
| nodeAffinityPreset.type | string | `""` |  |
| nodeAffinityPreset.values | list | `[]` |  |
| nodeSelector | object | `{}` |  |
| operator.serviceAccount.create | bool | `true` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.enabled | bool | `false` |  |
| persistence.mountPath | string | `"/data"` |  |
| persistence.size | string | `"10Gi"` |  |
| podAffinityPreset | string | `""` |  |
| podAnnotations | object | `{}` |  |
| podAntiAffinityPreset | string | `"soft"` |  |
| podLabels | object | `{"control-plane":"controller-manager","controller-tools.k8s.io":"1.0","app.kubernetes.io/component":"operator"}` |  |
| podSecurityContext.enabled | bool | `false` |  |
| podSecurityContext.fsGroup | int | `1001` |  |
| priorityClassName | string | `""` |  |
| profiling.enabled | bool | `false` |  |
| profiling.port | int | `6060` |  |
| rbac.enabled | bool | `true` |  |
| readinessProbe.enabled | bool | `false` |  |
| readinessProbe.httpGet.path | string | `/readyz` |  |
| readinessProbe.httpGet.port | int | `8081` |  |
| readinessProbe.failureThreshold | int | `6` |  |
| readinessProbe.initialDelaySeconds | int | `60` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| readinessProbe.successThreshold | int | `1` |  |
| readinessProbe.timeoutSeconds | int | `5` |  |
| replicaCount | int | `1` |  |
| resources | object | `{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` |  |
| secrets | object | `{}` |  |
| service.annotations | object | `{"prometheus.io/scrape":"true","prometheus.io/port":"8080","prometheus.io/scheme":"http"}` |  |
| service.labels | object | `{"control-plane":"controller-manager","controller-tools.k8s.io":"1.0"}` |  |
| service.ports | list | `[{"name":"https","port":443,"targetPort":"https"},{"name":"pprof","port":6060,"targetPort":"pprof"},{"name":"probes","port":8081,"targetPort":"probes"},{"name":"metrics","port":8091,"targetPort":"metrics"}]` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.name | string | `nil` |  |
| tests.httpChecks.default | bool | `false` |  |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` |  |
| updateStrategy.type | string | `"RollingUpdate"` |  |
| volumeMounts | list | `[]` |  |
| volumes | list | `[]` |  |
| webhook.enabled | bool | `false` |  |
| webhook.serverPort | int | `443` |  |
| webhook.tls.certDir | string | `/etc/webhooks/certs` |  |
| webhook.certs.secretName | string | `webhook-secret` |  |
| webhook.certs.generate | bool | `true` |  |
| webhook.certs.ca.crt | string | `""` |  |
| webhook.certs.server.tls.crt | string | `""` |  |
| webhook.certs.server.tls.key | string | `""` |  |
| webhook.certs.server.tls.key | string | `""` |  |

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
helm install my-release -f values.yaml dysnix/app
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Source Code

* <https://github.com/dysnix/charts>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | common | 1.x.x |
| https://dysnix.github.io/charts | base | 0.x.x |

## Persistence

AI-Scale-Doer is an AI-Scale operator microservice, which is used to manage k8s resources (scaling, etc.), 
interacts with the service Provider by communicating using the protobuf protocol.

## Configuration of service

For configuration service you can change list of options in [configMaps](https://github.com/dysnix/ai-scale-operator) value.
