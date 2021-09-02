#!/usr/bin/env python
import os
import re
import sys

KEYS = ['{{ join "','" .Values.bsc.nodeKeys }}']

def get_nodekey():
    node_id = re.search(r'^.*-(\d+)$', os.uname()[1]).group(1)
    return KEYS[int(node_id)]

if __name__ == '__main__':
    nodekey = get_nodekey()
    with open("{{ .Values.bsc.base_path }}/geth/nodekey", "w") as f:
        sys.stdout.write("Node key: {}".format(nodekey))
        f.write(nodekey)
