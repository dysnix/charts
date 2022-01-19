#!/usr/bin/env python
import os
import sys
import ipaddress
import json

nodeKeysFileName = "/generated-config/{{ .Values.bsc.nodekeysFileName }}"

def get_nodekey(nodeKeysFileName):
    addr=ipaddress.ip_address(os.environ['MY_POD_IP'])
    net=ipaddress.ip_network("{{ .Values.bsc.podRange }}")
    if addr in net:
      node_id=int(addr)-int(net[0])
    else:
      sys.stdout.write("Pod address "+str(addr)+" in not inside network "+str(net))
      sys.exit(1)
    with open(nodeKeysFileName, "r") as f:
      KEYS=json.load(f)
      return KEYS[node_id]

if __name__ == '__main__':
    nodekey = get_nodekey(nodeKeysFileName)
    with open("{{ .Values.bsc.base_path }}/geth/nodekey", "w") as f:
        sys.stdout.write("Node key: {}".format(nodekey))
        f.write(nodekey)
