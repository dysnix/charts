#!/bin/bash

set -u

# Set the database connection variables
DB_USER="${DB_USER:-monitor}"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-6032}"

# Health check configuration with default values
PROXYSQL_DIFF_CHECK_LIMIT=${PROXYSQL_DIFF_CHECK_LIMIT:-10}
PROXYSQL_KILL_IF_HEALTCHECK_FAILED=${PROXYSQL_KILL_IF_HEALTCHECK_FAILED:-true}
PROXYSQL_HEALTH_CHECK_FAILURES=${PROXYSQL_HEALTH_CHECK_FAILURES:-3}

export MYSQL_PWD="${DB_PASS:-monitor}"

# Locate mysql or mariadb client binary
function find_mysql_client() {
    if command -v mysql >/dev/null 2>&1; then
        echo "mysql"
    elif command -v mariadb >/dev/null 2>&1; then
        echo "mariadb"
    else
        echo "[$(date -Ins)] [ERROR] Neither 'mysql' nor 'mariadb' client is installed." >&2
        exit 1
    fi
}

MYSQL_CLIENT=$(find_mysql_client)

function mysql_cli() {
  $MYSQL_CLIENT -u "$DB_USER" -h "$DB_HOST" -P "$DB_PORT" --skip-column-names --batch -e "$1"
}

function run_diff_check_count() {
  local diff_check_count
  diff_check_count=$(mysql_cli "SELECT COUNT(diff_check) FROM stats_proxysql_servers_checksums WHERE diff_check > $PROXYSQL_DIFF_CHECK_LIMIT;")

  if [[ "$diff_check_count" == 0 ]]; then
    echo "[$(date -Ins)] [INFO] ProxySQL Cluster diff_check OK. diff_check < $PROXYSQL_DIFF_CHECK_LIMIT"
    return 0
  else
    local result
    result=$(mysql_cli "SELECT hostname, port, name, version, FROM_UNIXTIME(epoch) epoch, checksum, FROM_UNIXTIME(changed_at) changed_at, FROM_UNIXTIME(updated_at) updated_at, diff_check, DATETIME('NOW') FROM stats_proxysql_servers_checksums WHERE diff_check > $PROXYSQL_DIFF_CHECK_LIMIT ORDER BY name;")
    echo "$result"
    echo "[$(date -Ins)] [ERROR] ProxySQL Cluster diff_check CRITICAL. diff_check >= $PROXYSQL_DIFF_CHECK_LIMIT." >&2
    return 1
  fi
}

# Call the health check function once for Kubernetes probes
run_diff_check_count
