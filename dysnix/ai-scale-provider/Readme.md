# AI-Scale-Provider

[AI-Scale-Provider](https://github.com/dysnix/ai-scale-provider/Readme.md) is official ai-scale operator component 

## Introduction

This chart bootstraps a Deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.8+

## Installing the Chart
To install the chart with the release name `my-release`:

```console
$ helm repo add dysnix https://dysnix.github.io/charts
$ helm install my-release dysnix/ai-scale-provider
```

The command deploys AI-Scale-Provider on the Kubernetes cluster in the default configuration.
The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release`:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the ***`ai-scale-provider`*** and ***`base`*** library chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| args | list | `[]` |  |
| autoscaling.enabled | bool | `true` |  |
| autoscaling.maxReplicas | int | `10` |  |
| autoscaling.minReplicas | int | `1` |  |
| checksums | list | `[]` |  |
| command | list | `["/app","-conf=/etc/provider/configs/configs.yaml","-queries=/etc/provider/queries/queries.yaml","-logs=\"\""]` |  |
| commonAnnotations | object | `{}` |  |
| commonLabels | object | `{}` |  |
| configMaps | object | `{}` |  |
| configMaps.configs.data.configs.yaml | file | `{"debugMode":true,"profiling":{"enabled":false,"host":"localhost","port":6060},"metricsSource":{"metricsSourceType":"Prometheus","prometheus":{"url":"http://localhost:9090","concurrency":10,"httpTransport":{"maxIdleConnDuration":"1m","readTimeout":"7s","writeTimeout":"7s"}}},"grpc":{"enabled":true,"useReflection":true,"compression":{"enabled":false,"type":"None"},"health":{"host":"","port":8091},"connection":{"host":null,"port":8090,"readBufferSize":"100MiB","writeBufferSize":"100MiB","maxMessageSize":"30MiB","insecure":true}}}` |  |
| configMaps.queries.data.queries.yaml | file | `{"Cpu":["sum(\n        node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"})","sum(\n        node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"})","sum(\n        kube_pod_container_resource_requests{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\", resource=\"cpu\"})","sum(\n        node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"})\n    /sum(\n        kube_pod_container_resource_requests{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\", resource=\"cpu\"})"],"Memory":["sum(\n        container_memory_working_set_bytes{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\", container!=\"\", image!=\"\"})","sum(\n        container_memory_working_set_bytes{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\", container!=\"\", image!=\"\"})","sum(\n        kube_pod_container_resource_requests{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\", resource=\"memory\"})","sum(\n        container_memory_working_set_bytes{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\", container!=\"\", image!=\"\"})\n    /sum(\n        kube_pod_container_resource_requests{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\", resource=\"memory\"})","sum(\n        kube_pod_container_resource_limits{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\", resource=\"memory\"})","sum(\n        container_memory_working_set_bytes{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\", container!=\"\", image!=\"\"})\n    /sum(\n        kube_pod_container_resource_limits{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\", resource=\"memory\"})"],"Network":["(sum(irate(container_network_receive_bytes_total{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=~\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"}[{{ \"{{\" }} .Period.GetDurationString {{ \"}}\" }}])))","(sum(irate(container_network_transmit_bytes_total{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=~\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"}[{{ \"{{\" }} .Period.GetDurationString {{ \"}}\" }}])))","(sum(irate(container_network_receive_packets_total{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=~\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"}[{{ \"{{\" }} .Period.GetDurationString {{ \"}}\" }}])))","(sum(irate(container_network_transmit_packets_total{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=~\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"}[{{ \"{{\" }} .Period.GetDurationString {{ \"}}\" }}])))","(sum(irate(container_network_receive_packets_dropped_total{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=~\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"}[{{ \"{{\" }} .Period.GetDurationString {{ \"}}\" }}])))","(sum(irate(container_network_transmit_packets_dropped_total{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=~\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"}[{{ \"{{\" }} .Period.GetDurationString {{ \"}}\" }}])))","(sum(irate(container_network_receive_bytes_total{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=~\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"}[{{ \"{{\" }} .Period.GetDurationString {{ \"}}\" }}])))","(sum(irate(container_network_transmit_bytes_total{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=~\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"}[{{ \"{{\" }} .Period.GetDurationString {{ \"}}\" }}])))","(avg(irate(container_network_receive_bytes_total{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=~\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"}[{{ \"{{\" }} .Period.GetDurationString {{ \"}}\" }}])))","(avg(irate(container_network_transmit_bytes_total{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=~\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"}[{{ \"{{\" }} .Period.GetDurationString {{ \"}}\" }}])))","(sum(irate(container_network_receive_packets_total{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=~\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"}[{{ \"{{\" }} .Period.GetDurationString {{ \"}}\" }}])))","(sum(irate(container_network_transmit_packets_total{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=~\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"}[{{ \"{{\" }} .Period.GetDurationString {{ \"}}\" }}])))","(sum(irate(container_network_receive_packets_dropped_total{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=~\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"}[{{ \"{{\" }} .Period.GetDurationString {{ \"}}\" }}])))","(sum(irate(container_network_transmit_packets_dropped_total{cluster=\"{{ \"{{\" }} .Cluster {{ \"}}\" }}\", namespace=~\"{{ \"{{\" }} .Namespace {{ \"}}\" }}\"}[{{ \"{{\" }} .Period.GetDurationString {{ \"}}\" }}])))"]}` |  |
| containerPorts | list | `[]` |  |
| containerSecurityContext.enabled | bool | `false` |  |
| containerSecurityContext.runAsUser | int | `1001` |  |
| dnsPolicy | string | `"ClusterFirst"` |  |
| env | object | `{}` |  |
| envFrom | list | `[]` |  |
| hostAliases | list | `[]` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.registry | string | `""` |  |
| image.repository | string | `"alex6021710/ai-scale-provider"` |  |
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
| livenessProbe.exec.command | list | `[ "/bin/grpc_health_probe", "-addr=:8090" ]` |  |
| livenessProbe.failureThreshold | int | `6` |  |
| livenessProbe.initialDelaySeconds | int | `60` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.successThreshold | int | `1` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| name | string | `nil` |  |
| nodeAffinityPreset.key | string | `""` |  |
| nodeAffinityPreset.type | string | `""` |  |
| nodeAffinityPreset.values | list | `[]` |  |
| nodeSelector | object | `{}` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.enabled | bool | `false` |  |
| persistence.mountPath | string | `"/data"` |  |
| persistence.size | string | `"10Gi"` |  |
| podAffinityPreset | string | `""` |  |
| podAnnotations | object | `{}` |  |
| podAntiAffinityPreset | string | `"soft"` |  |
| podLabels | object | `{}` |  |
| podSecurityContext.enabled | bool | `false` |  |
| podSecurityContext.fsGroup | int | `1001` |  |
| priorityClassName | string | `""` |  |
| profiling.enabled | bool | `false` |  |
| profiling.port | int | `6060` |  |
| readinessProbe.enabled | bool | `false` |  |
| readinessProbe.exec.command | list | `[ "/bin/grpc_health_probe", "-addr=:8090" ]` |  |
| readinessProbe.failureThreshold | int | `6` |  |
| readinessProbe.initialDelaySeconds | int | `60` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| readinessProbe.successThreshold | int | `1` |  |
| readinessProbe.timeoutSeconds | int | `5` |  |
| resources | object | `{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` |  |
| secrets | object | `{}` |  |
| service.annotations | object | `{}` |  |
| service.labels | object | `{}` |  |
| service.ports | list | `[{"name":"grpc","port":8090,"targetPort":"grpc"}]` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.name | string | `nil` |  |
| tests.httpChecks.default | bool | `false` |  |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` |  |
| updateStrategy.type | string | `"RollingUpdate"` |  |
| volumeMounts | list | `[{"name":"configs","mountPath":"/etc/provider/configs","readOnly":true},{"name":"queries","mountPath":"/etc/provider/queries","readOnly":true}]` |  |
| volumes | list | `[{"name":"configs","configMap":{"name":"{{ include \"common.names.fullname\" $ }}-configs"}},{"name":"queries","configMap":{"name":"{{ include \"common.names.fullname\" $ }}-queries"}}]` |  |

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

AI-Scale-Provider is an AI-Scale operator microservice, which is used to receive and group metrics from an external source (currently only Prometheus is supported), 
further post-processing of these metrics to the form described in the proto file [proto files](https://github.com/dysnix/ai-scale-proto) of the AI-Scale component interaction protocol.

## Configuration of service

For configuration service you can change list of options in [configMaps](https://github.com/dysnix/ai-scale-provider) value.
