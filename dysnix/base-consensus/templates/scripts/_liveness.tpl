#!/usr/bin/env bash
# shellcheck disable=SC3040

# base-consensus liveness probe. Two stages:
#
#   1. GET /healthz on the RPC port. The consensus HTTP server normally stays
#      up even in soft-failure modes, but a non-200 here is a clear hard
#      failure — fail fast with a distinct message.
#
#   2. POST optimism_syncStatus, read `unsafe_l2.number`, and compare to the
#      last value saved in STATE_FILE. Only update the file when the head
#      advances, so its mtime is the time of the last advance. "Head hasn't
#      moved in N seconds" becomes "STATE_FILE mtime is N seconds old".
#      Catches the wedge we hit on 2026-05-23 19:59Z: /healthz kept returning
#      200 while the engine actor was dead and the unsafe head was frozen
#      for 4 hours.
#
# /tmp is the container's writable rootfs layer (no readOnlyRootFilesystem),
# so the state file lives across probe invocations and resets on container
# restart — which is correct: a fresh container should re-baseline.
#
# Usage: liveness.sh <max head-stall seconds> [state file]

set -e

MAX_AGE="${1:?Usage: $0 <max head-stall seconds> [state file]}"
STATE_FILE="${2:-/tmp/last_unsafe_head.txt}"
RPC_PORT="{{ .Values.config.rpc.port }}"
URL="http://127.0.0.1:${RPC_PORT}"

# Stage 1: /healthz — fast guard against a half-dead HTTP server.
# curl already prints "000" via %{http_code} on connection failure; the
# trailing `|| true` keeps `set -e` from killing the script before we reach
# the FAIL message. Don't add `|| echo 000` — that double-prints to "000000".
hz=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 3 "${URL}/healthz" || true)
if [ "${hz}" != "200" ]; then
    echo "FAIL: /healthz returned ${hz:-000}"
    exit 1
fi

# Stage 2: optimism_syncStatus → unsafe_l2.number
resp=$(curl -sS --max-time 5 -X POST -H 'content-type: application/json' \
    --data '{"jsonrpc":"2.0","method":"optimism_syncStatus","id":1}' "${URL}") || {
    echo "FAIL: optimism_syncStatus request failed"
    exit 1
}

unsafe_number=$(printf '%s' "${resp}" | python3 -c '
import json, sys
try:
    body = json.load(sys.stdin)
except Exception as e:
    sys.stderr.write("parse error: " + str(e) + "\n"); sys.exit(2)
if "error" in body:
    sys.stderr.write("rpc error: " + str(body["error"]) + "\n"); sys.exit(2)
n = body.get("result", {}).get("unsafe_l2", {}).get("number")
if n is None:
    sys.stderr.write("unsafe_l2.number missing from result\n"); sys.exit(2)
print(int(n))
') || { echo "FAIL: could not parse unsafe_l2.number"; exit 1; }

# Update state file ONLY when the head advances. Mtime tracks last advance.
saved=""
[ -f "${STATE_FILE}" ] && saved=$(cat "${STATE_FILE}")
if [ "${unsafe_number}" != "${saved}" ]; then
    echo "${unsafe_number}" > "${STATE_FILE}"
fi

age=$(( $(date +%s) - $(date -r "${STATE_FILE}" +%s) ))

if [ "${age}" -gt "${MAX_AGE}" ]; then
    if [ "${unsafe_number}" = "0" ]; then
        echo "FAIL: unsafe head still at block 0 after ${age}s — consensus never connected to peers/engine"
    else
        echo "FAIL: unsafe head stuck at block ${unsafe_number} for ${age}s > ${MAX_AGE}s"
    fi
    exit 1
fi

echo "OK: unsafe head at block ${unsafe_number} (age ${age}s)"
