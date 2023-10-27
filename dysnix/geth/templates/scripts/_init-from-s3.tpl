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
      inodes=$(df -Phi "$DATA_DIR" | tail -n 1 | awk '{print $3}')
      size=$(df -P -BG "$DATA_DIR" | tail -n 1 | awk '{print $3}')G
      echo -e "$(date -Iseconds) | SOURCE TOTAL ${remote_stats} | DST USED Inodes:\t${inodes} Size:\t${size}"
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
  # cleanup data always, s5cmd does not support "true" sync, it does not save object's timestamps
  # https://github.com/peak/s5cmd/issues/532
  echo "Cleaning up local data..."
  rm -rf "$ANCIENT_DIR"
  rm -rf "$CHAINDATA_DIR"
  # recreate data directories
  mkdir -p "$CHAINDATA_DIR"
  mkdir -p "$ANCIENT_DIR"

  echo "Starting download data from S3..."
  progress start

  # perform remote snapshot download and remove local objects which don't exist in snapshot
  # run two jobs in parallel, one for chaindata, second for ancient data
  time "$S5CMD" --stat sync $EXCLUDE_ANCIENT "s3://${CHAINDATA_URL}/*" "${CHAINDATA_DIR}/" >/dev/null &
  download_chaindata=$!
  time nice "$S5CMD" --stat sync --part-size 200 --concurrency 2 $EXCLUDE_CHAINDATA "s3://${ANCIENT_URL}/*" "${ANCIENT_DIR}/" >/dev/null &
  download_ancient=$!

  # handle interruption / termination
  trap 'interrupt ${download_chaindata} ${download_ancient} ${progress_pid}' INT TERM
  # wait for all syncs to complete
  wait $download_chaindata $download_ancient

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