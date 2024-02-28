#!/usr/bin/env sh
# shellcheck disable=SC2086,SC3037

set -e

. /scripts/s3-env.sh

process_inputs() {
  # enable sync via env variable
  if [ "$SYNC_TO_S3" != "True" ]; then
    echo "Sync is not enabled in config, exiting"
    exit 0
  fi
  # check for S3 credentials
  if [ -z "$S3_ENDPOINT_URL" ] || [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "S3 credentials are not provided, exiting"
    exit 1
  fi
}

check_recent_init() {
  # if node has been initialized from snapshot <30 mins ago, skip upload
  is_recent=$(find "$INITIALIZED_FILE" -type f -mmin +30 | wc -l | tr -d '[:blank:]')

  if [ -f "$INITIALIZED_FILE" ] && [ "$is_recent" -eq 0 ]; then
    echo "Node has been initialized recently, skipping the upload. Exiting..."; exit 0
  fi
}

# stop all background processes
interrupt() {
  echo "Got interrupt signal, stopping..."
  for i in "$@"; do kill $i; done
}

sync() {
  # add lockfile while uploading
  # shellcheck disable=SC3028
  echo "${HOSTNAME} $(date +%s)" | "$S5CMD" pipe "s3://${LOCKFILE_URL}"

  # perform upload of local data and remove destination objects which don't exist locally
  time "$S5CMD" --stat sync --delete "${DATA_DIR}/" "s3://${S3_BASE_URL}${S3_DATA_DIR}/" &
  upload_data=$!

  # handle interruption / termination
  trap 'interrupt ${upload_data}' INT TERM
  # wait for upload to complete
  wait $upload_data

  # mark upload as completed
  date +%s | "$S5CMD" pipe "s3://${COMPLETED_URL}"
  "$S5CMD" rm "s3://${LOCKFILE_URL}" || true
}

update_stats() {
  inodes=$(df -Phi "${DATA_DIR}" | tail -n 1 | awk '{print $3}')
  size=$(df -P -BG "${DATA_DIR}" | tail -n 1 | awk '{print $3}')G
  echo -ne "Inodes:\t${inodes} Size:\t${size}" | "$S5CMD" pipe "s3://${STATS_URL}"
}

main() {
  process_inputs
  check_recent_init
  sync
  update_stats
}

main