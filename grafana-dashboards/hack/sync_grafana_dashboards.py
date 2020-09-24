#!/usr/bin/env python3
"""Fetch dashboards from provided urls into this chart."""
import json
import textwrap
import re
from os import makedirs, path

import requests
import yaml
from yaml.representer import SafeRepresenter
from jsonpath_ng import jsonpath
from jsonpath_ng.ext import parse


# https://stackoverflow.com/a/20863889/961092
class LiteralStr(str):
    pass


def change_style(style, representer):
    def new_representer(dumper, data):
        scalar = representer(dumper, data)
        scalar.style = style
        return scalar

    return new_representer


# Source files list
charts = [
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/master/manifests/grafana-dashboardDefinitions.yaml',
        'destination': '../templates/dashboards-1.14',
        'type': 'yaml',
        'min_kubernetes': '1.14.0-0'
    },
    {
        'source': 'https://raw.githubusercontent.com/etcd-io/etcd/master/Documentation/op-guide/grafana.json',
        'destination': '../templates/dashboards-1.14',
        'type': 'json',
        'min_kubernetes': '1.14.0-0'
    },
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/release-0.1/manifests/grafana-dashboardDefinitions.yaml',
        'destination': '../templates/dashboards',
        'type': 'yaml',
        'min_kubernetes': '1.10.0-0',
        'max_kubernetes': '1.14.0-0'
    },
    {
        'source': 'https://raw.githubusercontent.com/etcd-io/etcd/master/Documentation/op-guide/grafana.json',
        'destination': '../templates/dashboards',
        'type': 'json',
        'min_kubernetes': '1.10.0-0',
        'max_kubernetes': '1.14.0-0'
    },
]

# Additional conditions map
condition_map = {
    'grafana-coredns-k8s': ' .Values.dashboards.enable.coreDns',
    'etcd': ' .Values.dashboards.enable.kubeEtcd',
    'apiserver': ' .Values.dashboards.enable.kubeApiServer',
    'controller-manager': ' .Values.dashboards.enable.kubeControllerManager',
    'kubelet': ' .Values.dashboards.enable.kubelet',
    'proxy': ' .Values.dashboards.enable.kubeProxy',
    'scheduler': ' .Values.dashboards.enable.kubeScheduler',
    'node-rsrc-use': ' .Values.dashboards.enable.nodeExporter',
    'node-cluster-rsrc-use': ' .Values.dashboards.enable.nodeExporter',
    'prometheus-remote-write': ' .Values.dashboards.enable.prometheusRemoteWriteDashboards'
}

# standard header
header = '''{{- /*
Generated from '%(name)s' from %(url)s
Do not change in-place! In order to change this file first read following link:
https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack/hack
*/ -}}
{{- $kubeTargetVersion := default .Capabilities.KubeVersion.GitVersion .Values.kubeTargetVersionOverride }}
{{- if and (semverCompare ">=%(min_kubernetes)s" $kubeTargetVersion) (semverCompare "<%(max_kubernetes)s" $kubeTargetVersion) .Values.dashboards.defaultDashboardsEnabled%(condition)s }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ printf "%%s-%%s" (include "grafana-dashboards.fullname" $) "%(name)s" | trunc 63 | trimSuffix "-" }}
  annotations:
{{ toYaml .Values.grafana.sidecar.dashboards.annotations | indent 4 }}
  labels:
    {{- if $.Values.grafana.sidecar.dashboards.label }}
    {{ $.Values.grafana.sidecar.dashboards.label }}: "1"
    {{- end }}
    app: {{ template "grafana-dashboards.name" $ }}
{{ include "grafana-dashboards.labels" $ | indent 4 }}
data:
'''

content_template_subst_map = {
    'cluster_hide': '.Values.clusterFederation.enabled | ternary 0 2'
}

JP_CLUSTER_LABEL = "$.templating.list[?(@.name=='cluster')]"


def init_yaml_styles():
    represent_literal_str = change_style('|', SafeRepresenter.represent_str)
    yaml.add_representer(LiteralStr, represent_literal_str)


def escape(s):
    return s.replace("{{", "{{`{{").replace("}}", "}}`}}").replace("{{`{{", "{{`{{`}}").replace("}}`}}", "{{`}}`}}")


def yaml_str_repr(struct, indent=2):
    """represent yaml as a string"""
    text = yaml.dump(
        struct,
        width=1000,  # to disable line wrapping
        default_flow_style=False  # to disable multiple items on single line
    )
    text = escape(text)  # escape {{ and }} for helm
    text = textwrap.indent(text, ' ' * indent)
    return text


def write_group_to_file(resource_name, content, url, destination, min_kubernetes, max_kubernetes):
    # initialize header
    lines = header % {
        'name': resource_name,
        'url': url,
        'condition': condition_map.get(resource_name, ''),
        'min_kubernetes': min_kubernetes,
        'max_kubernetes': max_kubernetes
    }

    filename_struct = {resource_name + '.json': (LiteralStr(make_content_template(content)))}
    # rules themselves
    lines += yaml_str_repr(filename_struct)

    # footer
    lines += '{{- end }}'

    filename = resource_name + '.yaml'
    new_filename = "%s/%s" % (destination, filename)

    # make sure directories to store the file exist
    makedirs(destination, exist_ok=True)

    # recreate the file
    with open(new_filename, 'w') as f:
        f.write(render_content_template(lines))

    print("Generated %s" % new_filename)


def make_content_template(content):
    jp_expr = parse(JP_CLUSTER_LABEL)
    data = json.loads(content)

    for match in jp_expr.find(data):
        match.value['hide'] = r'##cluster_hide##'
        jp_expr.update(data, match.value)

    return json.dumps(data, indent=4)


def render_content_template(content):
    for tpl, subst in content_template_subst_map.items():
        new_content = re.sub(r'"##%s##"' % tpl, '{{ %s }}' % subst, content, 0, re.MULTILINE)
        content = new_content

    return content

def main():
    init_yaml_styles()
    # read the rules, create a new template file per group
    for chart in charts:
        print("Generating rules from %s" % chart['source'])
        response = requests.get(chart['source'])
        if response.status_code != 200:
            print('Skipping the file, response code %s not equals 200' % response.status_code)
            continue
        raw_text = response.text

        if ('max_kubernetes' not in chart):
            chart['max_kubernetes']="9.9.9-9"

        if chart['type'] == 'yaml':
            yaml_text = yaml.full_load(raw_text)
            groups = yaml_text['items']
            for group in groups:
                for resource, content in group['data'].items():
                    write_group_to_file(resource.replace('.json', ''), content, chart['source'], chart['destination'], chart['min_kubernetes'], chart['max_kubernetes'])
        elif chart['type'] == 'json':
            json_text = json.loads(raw_text)
            # is it already a dashboard structure or is it nested (etcd case)?
            flat_structure = bool(json_text.get('annotations'))
            if flat_structure:
                resource = path.basename(chart['source']).replace('.json', '')
                write_group_to_file(resource, json.dumps(json_text, indent=4), chart['source'], chart['destination'], chart['min_kubernetes'], chart['max_kubernetes'])
            else:
                for resource, content in json_text.items():
                    write_group_to_file(resource.replace('.json', ''), json.dumps(content, indent=4), chart['source'], chart['destination'], chart['min_kubernetes'], chart['max_kubernetes'])
    print("Finished")


if __name__ == '__main__':
    main()
