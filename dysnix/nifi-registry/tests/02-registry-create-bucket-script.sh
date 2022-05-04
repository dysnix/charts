#!/bin/bash -x

export K8SNODEIP=$(kubectl get node -o json | jq -r '.items[0].status.addresses[0].address')
export K8SPORT=$(kubectl get svc browserless -o json | jq -r '.spec.ports[0].nodePort')
export NIFIREGURL='https://nifi-registry.default.svc.cluster.local:18443/nifi-registry/'

OLDPWD=$PWD
cd $HOME

mkdir -p $HOME/screenshots
node_modules/mocha/bin/_mocha $OLDPWD/tests/02-registry-create-bucket.js --timeout 30000
