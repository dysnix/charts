#!/usr/bin/env bash

# This script continuously monitors for active TCP connections to a specified ProxySQL service port
# and, if any are found, it pauses execution for a random duration between one and three seconds
# before checking again. It exits when there are no more active connections to the specified port.

set -euo pipefail

PROXYSQL_SERVICE_PORT=${PROXYSQL_SERVICE_PORT_PROXY:-6033}
SLEEP_MAX=3 # Maximum sleep duration in seconds.
HEX_PORT=$(printf ':%04X' $PROXYSQL_SERVICE_PORT) # Convert the port number to a padded hexadecimal string.

echo "Waiting for ProxySQL queries to finish..."

# Retrieves IP addresses of established connections to the ProxySQL service port
function get_connected_ips() {
  local connected_ips=()
  # Loop over all proxysql process IDs
  for pid in $(pidof proxysql 2>/dev/null || echo ""); do
    # Read related tcp connection information, filter by established connections on proxy port, extract IPs, and remove duplicates
    while read -r ip; do
      connected_ips+=("$ip")
    done < <(awk 'toupper($0) ~ /'"$HEX_PORT"' [0-9A-F]+:[0-9A-F]+ 01/ {print substr($3,1,length($3)-5)}' /proc/${pid}/net/tcp | sort -u)
  done
  echo "${connected_ips[@]}"
}

# Converts a hexadecimal IP address to its decimal representation
function convert_hex_ip_to_decimal() {
  local hex_ip=$1
  local dec_ip=""

  # Handle endianness and convert each pair of hex characters to decimal
  for i in {6..1..2}; do
    dec_ip+=".$((16#${hex_ip:i-2:2}))"
  done
  echo "${dec_ip:1}" # Remove the leading dot before returning the decimal IP
}

# Main loop that checks for and handles active ProxySQL connections
while true; do
  connected_ips_hex=( $(get_connected_ips) ) # Retrieve list of currently connected IP addresses in hexadecimal format

  # If no connections are found, then exit
  if [ ${#connected_ips_hex[@]} -eq 0 ]; then
    echo "Done. Exiting..."
    exit 0
  fi

  # Convert all hexadecimal IP addresses to decimal notation
  connected_ips_dec=()
  for ip_hex in "${connected_ips_hex[@]}"; do
    connected_ips_dec+=( "$(convert_hex_ip_to_decimal "$ip_hex")" )
  done

  # Print the number of unique connected IPs
  echo "Connected IPs: ${#connected_ips_dec[@]}"
  echo "Sleeping..."
  sleep $(( RANDOM % SLEEP_MAX + 1 ))
done
