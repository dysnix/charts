#!/bin/bash

set -u

# Set the database connection variables
export DB_USER="${PROXYSQL_HEALTHCHECK_DB_USER:-monitor}"
export DB_HOST="${PROXYSQL_HEALTHCHECK_DB_HOST:-127.0.0.1}"
export DB_PORT="${PROXYSQL_HEALTHCHECK_DB_PORT:-6032}"
export MYSQL_PWD="${PROXYSQL_HEALTHCHECK_DB_PASS:-monitor}"

# Health check configuration with default values
PROXYSQL_HEALTHCHECK_DIFF_CHECK_LIMIT=${PROXYSQL_HEALTHCHECK_DIFF_CHECK_LIMIT:-10}

# Locate mysql or mariadb client binary
function find_mysql_client() {
    if command -v mysql >/dev/null 2>&1; then
        echo "mysql"
    elif command -v mariadb >/dev/null 2>&1; then
        echo "mariadb"
    else
        log_error "Neither 'mysql' nor 'mariadb' client is installed."
        exit 1
    fi
}

MYSQL_CLIENT=$(find_mysql_client)

function log_info() {
  echo "[$(date -Ins)] [INFO] $1"
}

function log_error() {
  echo "[$(date -Ins)] [ERROR] $1" >&2
}

function mysql_cli() {
  $MYSQL_CLIENT -u "$DB_USER" -h "$DB_HOST" -P "$DB_PORT" --skip-column-names --batch -e "$1"
}

function run_diff_check_count() {
  local diff_check_count
  diff_check_count=$(mysql_cli "SELECT COUNT(diff_check) FROM stats_proxysql_servers_checksums WHERE diff_check > $PROXYSQL_HEALTHCHECK_DIFF_CHECK_LIMIT;")

  if [[ "$diff_check_count" == 0 ]]; then
    log_info "ProxySQL Cluster diff_check OK. diff_check < $PROXYSQL_HEALTHCHECK_DIFF_CHECK_LIMIT"
    return 0
  else
    local result
    result=$(mysql_cli "SELECT hostname, port, name, version, FROM_UNIXTIME(epoch) epoch, checksum, FROM_UNIXTIME(changed_at) changed_at, FROM_UNIXTIME(updated_at) updated_at, diff_check, DATETIME('NOW') FROM stats_proxysql_servers_checksums WHERE diff_check > $PROXYSQL_HEALTHCHECK_DIFF_CHECK_LIMIT ORDER BY name;")
    echo "$result"
    log_error "ProxySQL Cluster diff_check CRITICAL. diff_check >= $PROXYSQL_HEALTHCHECK_DIFF_CHECK_LIMIT."
    return 1
  fi
}

# Call the health check function once for Kubernetes probes
run_diff_check_count
