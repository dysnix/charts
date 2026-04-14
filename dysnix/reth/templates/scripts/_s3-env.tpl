#!/usr/bin/env sh

export S5CMD=/s5cmd

# reth-specific exclusion: always exclude MDBX lock file
export EXCLUDE_LOCK="--exclude mdbx.lck"

# local directory structure config
export DB_DIR="${DB_DIR?DB_DIR not provided.}"
export STATIC_FILES_DIR="${STATIC_FILES_DIR?STATIC_FILES_DIR not provided.}"
export INITIALIZED_FILE="${INITIALIZED_FILE?INITIALIZED_FILE not provided.}"
export INCLUDE_ROCKSDB="${INCLUDE_ROCKSDB:-False}"

# s3 directory structure config
export S3_BASE_URL="${S3_BASE_URL?S3_BASE_URL not provided.}"
export S3_DB_URL="${S3_DB_URL?S3_DB_URL not provided.}"
export S3_STATIC_FILES_URL="${S3_STATIC_FILES_URL?S3_STATIC_FILES_URL not provided.}"
export S_COMPLETED="/completed"
export S_STATS="/stats"
export S_LOCKFILE="/lockfile"
export DB_URL="${S3_BASE_URL}${S3_DB_URL}"
export STATIC_FILES_URL="${S3_BASE_URL}${S3_STATIC_FILES_URL}"
export COMPLETED_URL="${S3_BASE_URL}${S_COMPLETED}"
export LOCKFILE_URL="${S3_BASE_URL}${S_LOCKFILE}"
export STATS_URL="${S3_BASE_URL}${S_STATS}"

# optional rocksdb indices
if [ "$INCLUDE_ROCKSDB" = "True" ]; then
  export ROCKSDB_DIR="${ROCKSDB_DIR?ROCKSDB_DIR not provided when INCLUDE_ROCKSDB=True}"
  export S3_ROCKSDB_URL="${S3_ROCKSDB_URL?S3_ROCKSDB_URL not provided when INCLUDE_ROCKSDB=True}"
  export ROCKSDB_URL="${S3_BASE_URL}${S3_ROCKSDB_URL}"
fi

# download/upload options
export FORCE_INIT="${FORCE_INIT:-False}"
