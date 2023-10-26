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
  # get destinations
  chaindata_dst=$("$S5CMD" cat "s3://${CHAINDATA_URL}")
  ancient_dst=$("$S5CMD" cat "s3://${ANCIENT_URL}")

  # add lockfile while uploading
  # shellcheck disable=SC3028
  echo "${HOSTNAME} $(date +%s)" | "$S5CMD" pipe "s3://${LOCKFILE_URL}"

  # perform upload of local data and remove destination objects which don't exist locally
  # run two jobs in parallel, one for chaindata, second for ancient data
  time "$S5CMD" --stat sync --delete $EXCLUDE_ANCIENT "${CHAINDATA_DIR}/" "s3://${chaindata_dst}/" >/dev/null &
  upload_chaindata=$!
  time nice "$S5CMD" --stat sync --delete --part-size 200 --concurrency 2 $EXCLUDE_CHAINDATA "${ANCIENT_DIR}/" "s3://${ancient_dst}/" >/dev/null &
  upload_ancient=$!

  # handle interruption / termination
  trap 'interrupt ${upload_chaindata} ${upload_ancient}' INT TERM
  # wait for parallel upload to complete
  wait $upload_chaindata $upload_ancient

  # mark upload as completed
  date +%s | "$S5CMD" pipe "s3://${COMPLETED_URL}"
  "$S5CMD" rm "s3://${LOCKFILE_URL}"
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