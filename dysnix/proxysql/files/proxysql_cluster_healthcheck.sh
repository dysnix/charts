#!/bin/bash

set -u

# Set the database connection variables
DB_USER="${DB_USER:-monitor}"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-6032}"

PROXYSQL_DIFF_CHECK_LIMIT=${PROXYSQL_DIFF_CHECK_LIMIT:-10}
PROXYSQL_KILL_IF_HEALTCHECK_FAILED=${PROXYSQL_KILL_IF_HEALTCHECK_FAILED:-true}

export MYSQL_PWD="${DB_PASS:-monitor}"

function mysql_cli() {
  mysql -u ${DB_USER} -h ${DB_HOST} -P ${DB_PORT} --skip-column-names --batch --ssl-mode=DISABLED -e "$1"
}

function run_diff_check_count() {
  DIFF_CHECK_COUNT=$(mysql_cli "SELECT COUNT(diff_check) FROM stats_proxysql_servers_checksums WHERE diff_check > ${PROXYSQL_DIFF_CHECK_LIMIT};")

  if [[ "${DIFF_CHECK_COUNT}" -ge 1 ]]; then
    echo "[$(date -Ins)] [INFO] ProxySQL Cluster diff_check OK. diff_check < ${PROXYSQL_DIFF_CHECK_LIMIT}"
  else
    RESULT=$(mysql_cli "SELECT hostname, port, name, version, FROM_UNIXTIME(epoch) epoch, checksum, FROM_UNIXTIME(changed_at) changed_at, FROM_UNIXTIME(updated_at) updated_at, diff_check, DATETIME('NOW') FROM stats_proxysql_servers_checksums WHERE diff_check > ${PROXYSQL_DIFF_CHECK_LIMIT} ORDER BY name;")
    echo "[$(date -Ins)] [WARN] ProxySQL Cluster diff_check WARNING. diff_check >= ${PROXYSQL_DIFF_CHECK_LIMIT}"
    echo "${RESULT}"
    if [[ "${PROXYSQL_KILL_IF_HEALTCHECK_FAILED}" == "true" ]]; then
      echo "[$(date -Ins)] [ERROR] Terminating proxysql process..."
      kill -s SIGTERM "$(pidof proxysql)"
    fi
    BACKOFF_SLEEP_TIME=$[ ( $RANDOM % 60 )  + 30 ]
    echo "[$(date -Ins)] [WARN] ProxySQL health check exiting in ${BACKOFF_SLEEP_TIME} seconds..."
    sleep ${BACKOFF_SLEEP_TIME}s
    exit 1
  fi
}

echo "[$(date -Ins)] [INFO] ProxySQL health check start..."
while true; do
  sleep $[ ( $RANDOM % 7 )  + 3 ]s
  run_diff_check_count
done
