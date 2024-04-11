#!/usr/bin/env sh

export S5CMD=/s5cmd

# local directory structure config
export DATA_DIR="${DATA_DIR?DATA_DIR not provided.}"
export INITIALIZED_FILE="${INITIALIZED_FILE?INITIALIZED_FILE not provided.}"

# s3 directory structure config
export S3_BASE_URL="${S3_BASE_URL?S3_BASE_URL not provided.}"
export S3_DATA_DIR="${S3_BASE_URL}/upload"
export S_COMPLETED="/completed"
export S_STATS="/stats"
export S_LOCKFILE="/lockfile"
export COMPLETED_URL="${S3_BASE_URL}${S_COMPLETED}"
export LOCKFILE_URL="${S3_BASE_URL}${S_LOCKFILE}"
export STATS_URL="${S3_BASE_URL}${S_STATS}"

# download/upload options
export FORCE_INIT="${FORCE_INIT:-False}"
