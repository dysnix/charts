#!/usr/bin/env sh

set -ex # -e exits on error
SRC_DIR=/config
DST_DIR=/generated-config
CONFIG_NAME=config.toml
TRUSTED_NODES_SRC_URL={{ .Values.bsc.trustedNodesSrcUrl }}
NODEKEYS_SRC_URL={{ .Values.bsc.nodekeysSrcUrl }}
NODEKEYS={{ .Values.bsc.nodekeysFileName }}
TRUSTED_NODES=trusted_nodes

{{ if and (eq .Values.controller "CloneSet") .Values.bsc.getNodeKey }}
gsutil cp "${NODEKEYS_SRC_URL}" "${DST_DIR}/${NODEKEYS}"
{{- end }}

# check if we really need to generate config
if [ "${GENERATE_CONFIG}" != "true" ];then
  echo "Config generation disabled, copying instead"
  cp -f "${SRC_DIR}/${CONFIG_NAME}" "${DST_DIR}/${CONFIG_NAME}"
  exit 0
fi

# config generation
cd /tmp

gsutil cp "${TRUSTED_NODES_SRC_URL}" "${TRUSTED_NODES}"

# # https://askubuntu.com/a/1175271
# # replace a matching line with a file content
# sed  -e "/^TrustedNodes.*/{r${TRUSTED_NODES}" -e "d}" "${SRC_DIR}/${CONFIG_NAME}" > "${DST_DIR}/${CONFIG_NAME}"
#
# if [ -s "${DST_DIR}/${CONFIG_NAME}" ];then
#   echo "Resulting config is empty"
#   exit 1
# fi

cp "${SRC_DIR}/${CONFIG_NAME}" "${DST_DIR}/${CONFIG_NAME}"
echo >> "${DST_DIR}/${CONFIG_NAME}"
cat "${TRUSTED_NODES}" >> "${DST_DIR}/${CONFIG_NAME}"
{{ if .Values.bsc.proxiedNodesSrcUrl }}
PROXIED_NODES_SRC_URL={{ .Values.bsc.proxiedNodesSrcUrl }}
PROXIED_NODES=proxied_nodes
gsutil cp "${PROXIED_NODES_SRC_URL}" "${PROXIED_NODES}"
echo >> "${DST_DIR}/${CONFIG_NAME}"
cat "${PROXIED_NODES}" >> "${DST_DIR}/${CONFIG_NAME}"
{{- end }}
