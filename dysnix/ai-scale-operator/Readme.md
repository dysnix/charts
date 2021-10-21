# AI-Scale-Operator

This is an umbrella helm chart for deploying all the necessary elements and microservices of the Ai-Scale stack.

## Introduction

This chart bootstraps a Deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.8+

## Installing the Chart
To install the chart with the release name `my-release`:

```console
$ helm repo add dysnix https://dysnix.github.io/charts
$ helm install my-release dysnix/ai-scale-operator
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
| ai-scale-doer | object | [***`<ai-scale-doer> values`***](https://github.com/dysnix/ai-scale-doer/#configuration) |  |
| ai-scale-provider | object | [***`<ai-scale-provider> values`***](https://github.com/dysnix/ai-scale-provider/#configuration) |  |


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
| https://dysnix.github.io/charts | ai-scale-doer | 0.x.x |
| https://dysnix.github.io/charts | ai-scale-provider | 0.x.x |

## Peculiarities

1) for the Service Provider to work correctly, replace the prometheus address in the configuration with a valid one
2) for the Service Doer to work correctly, add the necessary CR resources that the service will have to track