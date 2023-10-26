#!/usr/bin/env sh

export S5CMD=/s5cmd

# chaindata options
export EXCLUDE_ANCIENT="--exclude *.cidx --exclude *.ridx --exclude *.cdat --exclude *.rdat"
export EXCLUDE_CHAINDATA="--exclude *.ldb --exclude *.sst"

# local directory structure config
export DATA_DIR="${DATA_DIR:-/root/.ethereum}"
export CHAINDATA_DIR="${CHAINDATA_DIR:-${DATA_DIR}/geth/chaindata}"
export ANCIENT_DIR="${ANCIENT_DIR:-${CHAINDATA_DIR}/ancient}"
export INITIALIZED_FILE="${DATA_DIR}/.initialized"

# s3 config
export S3_BASE_URL="${S3_BASE_URL?S3_BASE_URL not provided.}"

# s3 directory structure config
export S_COMPLETED="/completed"
export S_CHAINDATA_URL="/chaindata_url"
export S_ANCIENT_URL="/ancient_url"
export S_STATS="/stats"
export S_LOCKFILE="/lockfile"
export COMPLETED_URL="${S3_BASE_URL}${S_COMPLETED}"
export LOCKFILE_URL="${S3_BASE_URL}${S_LOCKFILE}"
export STATS_URL="${S3_BASE_URL}${S_STATS}"
export CHAINDATA_URL="${S3_BASE_URL}${S_CHAINDATA_URL}"
export ANCIENT_URL="${S3_BASE_URL}${S_ANCIENT_URL}"

# download/upload options
export FORCE_INIT="${FORCE_INIT:-False}"