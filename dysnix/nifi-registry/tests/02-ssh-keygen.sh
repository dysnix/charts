#!/bin/bash -x

/bin/rm -f /tmp/id_rsa /tmp/id_rsa.pub
ssh-keygen -q -N "" -C "NiFi Registry Git" -b 4096 -t rsa -f /tmp/id_rsa
kubectl create secret generic nifi-registry-git-ssh --from-file=/tmp/id_rsa --from-file=/tmp/id_rsa.pub
