#!/bin/bash -x

/bin/rm -rf /tmp/helm-nifi-with-cert-manager
cd /tmp
git clone https://github.com/wknickless/helm-nifi.git helm-nifi-with-cert-manager
cd /tmp/helm-nifi-with-cert-manager
git checkout 2bb07f92bc2d74f8f6e0be1efe038b2147444dda
helm dep update
