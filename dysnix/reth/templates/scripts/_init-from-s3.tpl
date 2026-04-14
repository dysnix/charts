#!/usr/bin/env sh
# shellcheck disable=SC2086,SC3037

set -e

. /scripts/s3-env.sh

process_inputs() {
  # download even if already initialized
  if [ "$FORCE_INIT" = "True" ]; then
    echo "Force init enabled, existing data will be deleted."
    rm -f "$INITIALIZED_FILE"
  fi
  # check if we are already initialized
  if [ -f "$INITIALIZED_FILE" ]; then
    echo "Blockchain already initialized. Exiting..."; exit 0
  fi
  # check for S3 credentials
  if [ -z "$S3_ENDPOINT_URL" ] || [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "S3 credentials are not provided, exiting"; exit 1
  fi
}

progress() {
  remote_stats=$("$S5CMD" cat "s3://${STATS_URL}")
  case $1 in
  "start")
    while true; do
      files=$(find "$DB_DIR" "$STATIC_FILES_DIR" -type f 2>/dev/null | wc -l | tr -d '[:blank:]')
      size_mb=$(du -sm "$DB_DIR" "$STATIC_FILES_DIR" 2>/dev/null | awk '{sum+=$1} END{print sum}')
      size_gb=$(awk "BEGIN{printf \"%.1f\", ${size_mb:-0}/1024}")
      echo -e "$(date -Iseconds) | SOURCE TOTAL ${remote_stats} | DST USED Files:\t${files} Size:\t${size_gb}G"
      sleep 2
    done &
    progress_pid=$! ;;
  "stop")
    kill "$progress_pid"
    progress_pid=0 ;;
  "*")
    echo "Unknown arg" ;;
  esac
}

check_lockfile() {
  if "$S5CMD" cat "s3://${LOCKFILE_URL}" >/dev/null 2>&1; then
    echo "Found existing lockfile, snapshot might be corrupted. Aborting download.."
    exit 1
  fi
}

# stop all background tasks
interrupt() {
  echo "Got interrupt signal, stopping..."
  for i in "$@"; do kill $i; done
}

sync() {
  # cleanup data always, s5cmd does not support "true" sync
  echo "Cleaning up local data..."
  rm -rf "$DB_DIR"
  rm -rf "$STATIC_FILES_DIR"
  mkdir -p "$DB_DIR"
  mkdir -p "$STATIC_FILES_DIR"

  if [ "$INCLUDE_ROCKSDB" = "True" ]; then
    rm -rf "$ROCKSDB_DIR"
    mkdir -p "$ROCKSDB_DIR"
  fi

  echo "Starting download data from S3..."
  progress start

  # perform remote snapshot download
  # db: use large part-size and low concurrency because mdbx.dat is very large
  time "$S5CMD" --stat sync --part-size 200 --concurrency 2 $EXCLUDE_LOCK "s3://${DB_URL}/*" "${DB_DIR}/" >/dev/null &
  download_db=$!
  # static_files: many smaller immutable segments, default concurrency is fine
  time nice "$S5CMD" --stat sync "s3://${STATIC_FILES_URL}/*" "${STATIC_FILES_DIR}/" >/dev/null &
  download_static=$!

  # optional: rocksdb indices (saves rebuild time at startup)
  if [ "$INCLUDE_ROCKSDB" = "True" ]; then
    time nice "$S5CMD" --stat sync "s3://${ROCKSDB_URL}/*" "${ROCKSDB_DIR}/" >/dev/null &
    download_rocksdb=$!
  fi

  # handle interruption / termination
  trap 'interrupt ${download_db} ${download_static} ${download_rocksdb:-} ${progress_pid}' INT TERM
  wait $download_db $download_static ${download_rocksdb:-}

  progress stop

  # all done, mark as initialized
  touch "$INITIALIZED_FILE"
}


main() {
  process_inputs
  check_lockfile
  sync
}

main
