#!/usr/bin/env sh
set -ex

# env required
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

DATA_DIR="{{ .Values.bsc.base_path }}"
RMLIST="${DATA_DIR}/{{ .Values.gcsCleanup.rmlist }}"
RMLOG="${DATA_DIR}/{{ .Values.gcsCleanup.rmlog }}"
GSUTIL="/google-cloud-sdk/bin/gsutil"
GCLOUD="/google-cloud-sdk/bin/gcloud"
BOTOCONFIG="${HOME}/.boto"

# allow container interrupt
trap "{ exit 1; }" INT TERM

# disable gcloud auth
${GCLOUD} config set pass_credentials_to_gsutil false
# using env vars to auth to GCS, as we use these env vars for s5cmd already
set +x
echo -e "[Credentials]\ngs_access_key_id = ${AWS_ACCESS_KEY_ID}\ngs_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" > "${BOTOCONFIG}"
set -x

# creating empty list if missing, f.e .no sync-to-gcs were running
touch "${RMLIST}"

OBJ_TO_REMOVE=$(wc -l < "${RMLIST}")
set +e
if [ "${OBJ_TO_REMOVE}" -gt "10000" ];then
  split -l 2000 "${RMLIST}" /tmp/rmlist-
  find /tmp -name "rmlist-*" -print0| xargs -0 -P 50 -n1 -I{} bash -c "nice ${GSUTIL} rm -f -I < {}"
  echo "$(date -Iseconds) Removed objects: ${OBJ_TO_REMOVE}" | tee -a "${RMLOG}"
else
  if [ "${OBJ_TO_REMOVE}" -gt "0" ];then
    time ${GSUTIL} -m rm -I < "${RMLIST}"
    echo "$(date -Iseconds) Removed objects: ${OBJ_TO_REMOVE}" | tee -a "${RMLOG}"
  else
    echo "No objects to remove"
  fi
fi

# cleanup removal list
true > "${RMLIST}"

# sleep in an endless cycle to allow container interrupt
set +x
while true; do sleep 10;done
