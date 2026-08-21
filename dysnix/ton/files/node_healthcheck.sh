#!/bin/bash
# TON_ROOT="/var/ton-work/db"
# CONSOLE_PORT="30001"

ETC_ROOT="$TON_ROOT/etc"
LOG_ROOT="$TON_ROOT/log"
CERT_ROOT="$ETC_ROOT/node_certs"

SERVER_PUB="${CERT_ROOT}/server.pub"
CLIENT_CERT="${CERT_ROOT}/client"

if [ ! -f "${SERVER_PUB}" ]; then
    echo "Server keys not found, exiting"
    exit 1
fi

if [ ! -f "${CLIENT_CERT}" ]; then
    echo "Client keys not found, exiting"
    exit 1
fi

server_time=`validator-engine-console -p $SERVER_PUB -k $CLIENT_CERT -a 127.0.0.1:30001 -c getstats | grep unixtime | awk '{print $2}'`
current_time=`date +%s`
time_diff=$((current_time - server_time))
echo "Time difference: $time_diff"

if [ $time_diff -gt 2 ]; then
    echo "Time difference is greater than 2 seconds, exiting"
    exit 1
fi

exit 0