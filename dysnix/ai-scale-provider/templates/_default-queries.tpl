{{- define "default.service.queries" -}}
Cpu:
  - |-
    sum(
            node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace="{{ "{{" }} .Namespace {{ "}}" }}"})
  - |-
    sum(
            node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace="{{ "{{" }} .Namespace {{ "}}" }}"})
  - |-
    sum(
            kube_pod_container_resource_requests{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace="{{ "{{" }} .Namespace {{ "}}" }}", resource="cpu"})
  - |-
    sum(
            node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace="{{ "{{" }} .Namespace {{ "}}" }}"})
        /sum(
            kube_pod_container_resource_requests{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace="{{ "{{" }} .Namespace {{ "}}" }}", resource="cpu"})
Memory:
  - |-
    sum(
            container_memory_working_set_bytes{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace="{{ "{{" }} .Namespace {{ "}}" }}", container!="", image!=""})
  - |-
    sum(
            container_memory_working_set_bytes{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace="{{ "{{" }} .Namespace {{ "}}" }}", container!="", image!=""})
  - |-
    sum(
            kube_pod_container_resource_requests{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace="{{ "{{" }} .Namespace {{ "}}" }}", resource="memory"})
  - |-
    sum(
            container_memory_working_set_bytes{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace="{{ "{{" }} .Namespace {{ "}}" }}", container!="", image!=""})
        /sum(
            kube_pod_container_resource_requests{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace="{{ "{{" }} .Namespace {{ "}}" }}", resource="memory"})
  - |-
    sum(
            kube_pod_container_resource_limits{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace="{{ "{{" }} .Namespace {{ "}}" }}", resource="memory"})
  - |-
    sum(
            container_memory_working_set_bytes{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace="{{ "{{" }} .Namespace {{ "}}" }}", container!="", image!=""})
        /sum(
            kube_pod_container_resource_limits{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace="{{ "{{" }} .Namespace {{ "}}" }}", resource="memory"})
Network:
  - (sum(irate(container_network_receive_bytes_total{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace=~"{{ "{{" }} .Namespace {{ "}}" }}"}[{{ "{{" }} .Period.GetDurationString {{ "}}" }}])))
  - (sum(irate(container_network_transmit_bytes_total{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace=~"{{ "{{" }} .Namespace {{ "}}" }}"}[{{ "{{" }} .Period.GetDurationString {{ "}}" }}])))
  - (sum(irate(container_network_receive_packets_total{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace=~"{{ "{{" }} .Namespace {{ "}}" }}"}[{{ "{{" }} .Period.GetDurationString {{ "}}" }}])))
  - (sum(irate(container_network_transmit_packets_total{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace=~"{{ "{{" }} .Namespace {{ "}}" }}"}[{{ "{{" }} .Period.GetDurationString {{ "}}" }}])))
  - (sum(irate(container_network_receive_packets_dropped_total{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace=~"{{ "{{" }} .Namespace {{ "}}" }}"}[{{ "{{" }} .Period.GetDurationString {{ "}}" }}])))
  - (sum(irate(container_network_transmit_packets_dropped_total{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace=~"{{ "{{" }} .Namespace {{ "}}" }}"}[{{ "{{" }} .Period.GetDurationString {{ "}}" }}])))
  - (sum(irate(container_network_receive_bytes_total{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace=~"{{ "{{" }} .Namespace {{ "}}" }}"}[{{ "{{" }} .Period.GetDurationString {{ "}}" }}])))
  - (sum(irate(container_network_transmit_bytes_total{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace=~"{{ "{{" }} .Namespace {{ "}}" }}"}[{{ "{{" }} .Period.GetDurationString {{ "}}" }}])))
  - (avg(irate(container_network_receive_bytes_total{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace=~"{{ "{{" }} .Namespace {{ "}}" }}"}[{{ "{{" }} .Period.GetDurationString {{ "}}" }}])))
  - (avg(irate(container_network_transmit_bytes_total{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace=~"{{ "{{" }} .Namespace {{ "}}" }}"}[{{ "{{" }} .Period.GetDurationString {{ "}}" }}])))
  - (sum(irate(container_network_receive_packets_total{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace=~"{{ "{{" }} .Namespace {{ "}}" }}"}[{{ "{{" }} .Period.GetDurationString {{ "}}" }}])))
  - (sum(irate(container_network_transmit_packets_total{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace=~"{{ "{{" }} .Namespace {{ "}}" }}"}[{{ "{{" }} .Period.GetDurationString {{ "}}" }}])))
  - (sum(irate(container_network_receive_packets_dropped_total{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace=~"{{ "{{" }} .Namespace {{ "}}" }}"}[{{ "{{" }} .Period.GetDurationString {{ "}}" }}])))
  - (sum(irate(container_network_transmit_packets_dropped_total{cluster="{{ "{{" }} .Cluster {{ "}}" }}", namespace=~"{{ "{{" }} .Namespace {{ "}}" }}"}[{{ "{{" }} .Period.GetDurationString {{ "}}" }}])))
{{- end }}