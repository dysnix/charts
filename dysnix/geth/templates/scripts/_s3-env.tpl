#!/usr/bin/env sh

export S5CMD=/s5cmd

# chaindata options
export EXCLUDE_ANCIENT="--exclude *.cidx --exclude *.ridx --exclude *.cdat --exclude *.rdat"
export EXCLUDE_CHAINDATA="--exclude *.ldb --exclude *.sst"

# local directory structure config
export DATA_DIR="${DATA_DIR?DATA_DIR not provided.}"
export ANCIENT_DIR="${ANCIENT_DIR?ANCIENT_DIR not provided.}"
export INITIALIZED_FILE="${INITIALIZED_FILE?INITIALIZED_FILE not provided.}"

# s3 directory structure config
export S3_BASE_URL="${S3_BASE_URL?S3_BASE_URL not provided.}"
export S3_DATA_URL="${S3_DATA_URL?S3_DATA_URL not provided.}"
export S3_ANCIENT_URL="${S3_ANCIENT_URL?S3_ANCIENT_URL not provided.}"
export S_COMPLETED="/completed"
export S_STATS="/stats"
export S_LOCKFILE="/lockfile"
export DATA_URL="${S3_BASE_URL}${S3_DATA_URL}"
export ANCIENT_URL="${S3_BASE_URL}${S3_ANCIENT_URL}"
export COMPLETED_URL="${S3_BASE_URL}${S_COMPLETED}"
export LOCKFILE_URL="${S3_BASE_URL}${S_LOCKFILE}"
export STATS_URL="${S3_BASE_URL}${S_STATS}"

# download/upload options
export FORCE_INIT="${FORCE_INIT:-False}"
