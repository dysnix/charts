
import json
import os
from time import sleep

TON_ROOT = os.getenv('TON_ROOT', '/var/ton-work/db')
ETC_ROOT=f"{TON_ROOT}/etc"
GLOBAL_CONFIG=f"{ETC_ROOT}/global-config.json"
API_GLOBAL_CONFIG=f"{ETC_ROOT}/api-global-config.json"
CERT_ROOT=f"{ETC_ROOT}/node_certs"
NODE_CONFIG=f"{TON_ROOT}/config.json"
NODE_CONFIG_OUT=f"{TON_ROOT}/config.json"

if not os.path.exists(f"{CERT_ROOT}/json_liteserver"):
    print("Waiting for json_liteserver")
    sleep(2)

if os.path.exists(NODE_CONFIG):
    with open(NODE_CONFIG, 'r') as f:
        config = json.load(f)
        
# TON NODE CONFIG GENERATION
cert_files = [f for f in os.listdir(CERT_ROOT)]
if "json_server" in cert_files:
    server_cert: dict = json.load(open(f"{CERT_ROOT}/json_server"))
else:
    raise Exception("json_server not found")
    
if "json_client" in cert_files:
    client_cert: dict = json.load(open(f"{CERT_ROOT}/json_client"))
else:
    raise Exception("json_client not found")

if "json_liteserver" in cert_files:
    liteserver_cert: dict = json.load(open(f"{CERT_ROOT}/json_liteserver"))
else:
    raise Exception("json_liteserver not found")

config['control'] = [{
        "id": server_cert.get('PUB'),
        "port": int(os.getenv('CONSOLER_PORT', "30001")),
        "allowed": [
            {
                "id": client_cert.get('PUB'),
                "permissions": 15
            }
        ]
    }
]
config['liteservers'] = [
    {
        "id": liteserver_cert.get('PUB'),
        "port": int(os.getenv('LITESERVER_PORT', "43679"))
    }
]

with open(NODE_CONFIG_OUT, 'w') as f:
    json.dump(config, f, indent=4)

# HERE PART FOR TON-HTTP-API
# Need get global-config.json and change liteserver only to my node 
# This is 127.0.0.1 + port 43679

# Make ip 
# CERT str(codecs.encode(lite_cert_read, "base64")).replace("\n", "")[2:46]

import socket
import struct
import codecs
ip_local = "127.0.0.1"
if "liteserver.pub" in cert_files:
    f = open(f"{CERT_ROOT}/liteserver.pub", "rb+")
    lite_cert_read = f.read()[4:]
else: 
    raise Exception("liteserver.pub not found")
liteserver = [
    {
        "ip": struct.unpack('>i', socket.inet_aton(ip_local))[0],
        "port": int(os.getenv('LITESERVER_PORT', "43679")),
        "id": {
            "@type": "pub.ed25519",
            "key": str(codecs.encode(lite_cert_read, "base64").decode("utf-8").replace("\n", ""))
        }
    }
]

if os.path.exists(GLOBAL_CONFIG):
    with open(GLOBAL_CONFIG, 'r') as f:
        global_config = json.load(f)
else:
    raise Exception("global-config.json not found")

global_config['liteservers'] = liteserver

with open(API_GLOBAL_CONFIG, 'w') as f:
    json.dump(global_config, f, indent=4)

