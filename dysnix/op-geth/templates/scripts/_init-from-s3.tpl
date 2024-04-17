#!/usr/bin/env sh
# shellcheck disable=SC2086,SC3037

set -e

. /scripts/s3-env.sh

process_inputs() {
  # download even if we are already initialized
  if [ "$FORCE_INIT" = "True" ]; then
    echo "Force init enabled, existing data will be deleted."
    rm -f "$INITIALIZED_FILE"
  fi
  # check for S3 credentials
  if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
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
  # check if we are already initialized
  if [ -f "$INITIALIZED_FILE" ]; then
    echo "Blockchain already initialized. Exiting..."
    exit 0
  fi
  # s5cmd does not support "true" sync, it does not save object's timestamps
  # so we cleanup local datadir on our own
  # https://github.com/peak/s5cmd/issues/532
  echo "Cleaning up local data..."
  rm -rf "${DATA_DIR}"
  mkdir -p "${DATA_DIR}"

  echo "Starting download data from S3..."

  # handle interruption / termination
  trap 'interrupt ${progress_pid}' INT TERM
  progress start

  # download remote snapshot to an empty datadir
  time "$S5CMD" --stat --log error sync "s3://${S3_DATA_DIR}/*" "${DATA_DIR}/"
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