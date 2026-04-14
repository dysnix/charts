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
  # db: large single file, use large part-size and low concurrency
  time "$S5CMD" --stat sync --delete --part-size 200 --concurrency 2 $EXCLUDE_LOCK "${DB_DIR}/" "s3://${DB_URL}/" &
  upload_db=$!
  # static_files: many immutable segments, default concurrency
  time nice "$S5CMD" --stat sync --delete "${STATIC_FILES_DIR}/" "s3://${STATIC_FILES_URL}/" &
  upload_static=$!

  # optional: rocksdb indices (regenerable but saves rebuild time)
  if [ "$INCLUDE_ROCKSDB" = "True" ]; then
    time nice "$S5CMD" --stat sync --delete "${ROCKSDB_DIR}/" "s3://${ROCKSDB_URL}/" &
    upload_rocksdb=$!
  fi

  # handle interruption / termination
  trap 'interrupt ${upload_db} ${upload_static} ${upload_rocksdb:-}' INT TERM
  wait $upload_db $upload_static ${upload_rocksdb:-}

  # mark upload as completed
  date +%s | "$S5CMD" pipe "s3://${COMPLETED_URL}"
  "$S5CMD" rm "s3://${LOCKFILE_URL}"
}

update_stats() {
  files=$(find "$DB_DIR" "$STATIC_FILES_DIR" -type f 2>/dev/null | wc -l | tr -d '[:blank:]')
  size_mb=$(du -sm "$DB_DIR" "$STATIC_FILES_DIR" 2>/dev/null | awk '{sum+=$1} END{print sum}')
  size_gb=$(awk "BEGIN{printf \"%.1f\", ${size_mb:-0}/1024}")
  echo -ne "Files:\t${files} Size:\t${size_gb}G" | "$S5CMD" pipe "s3://${STATS_URL}"
}

main() {
  process_inputs
  check_recent_init
  sync
  update_stats
}

main
