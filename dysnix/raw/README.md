# dysnix/raw

The [dysnix/raw](https://github.com/dysnix/charts/tree/main/dysnix/raw) chart takes a list of Kubernetes resources and merges each resource with a default `metadata.labels` map and installs the result. Use this chart to generate arbitrary Kubernetes manifests instead of kubectl and scripts ;)

The Kubernetes resources can be "raw" ones defined under the `resources` key, or "templated" ones defined under the `templates` key.

## Usage

### Raw resources

#### STEP 1: Create a yaml file containing your raw resources.

Resources list can contain mixed types, i.e. include strings and maps simultaneously.

```
# raw-priority-classes.yaml
resources:
  - apiVersion: scheduling.k8s.io/v1beta1
    kind: PriorityClass
    metadata:
      name: common-critical
    value: 100000000
    globalDefault: false
    description: "This priority class should only be used for critical priority common pods."
  - |
      apiVersion: scheduling.k8s.io/v1beta1
      kind: PriorityClass
      metadata:
        name: common-critical-from-string
      value: 100000000
      globalDefault: false
      description: "This priority class should only be used for critical priority common pods."
```

#### STEP 2: Install your raw resources.

```
helm install raw-priority-classes dysnix/raw -f raw-priority-classes.yaml
```

### Templated resources

#### STEP 1: Create a yaml file containing your templated resources.

```
# values.yaml

templates:
- |
  apiVersion: v1
  kind: Secret
  metadata:
    name: common-secret
  stringData:
    mykey: {{ .Values.mysecret }}
```

#### STEP 2: Install your templated resources.

```
helm install mysecret dysnix/raw -f values.yaml
```
