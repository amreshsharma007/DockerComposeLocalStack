#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<EOF
Usage: rm.sh [-e ENDPOINT] <target> [aws-rm-opts...]

Runs: aws s3 rm with optional --endpoint-url.

Environment:
  AWS_ENDPOINT_URL  default endpoint if -e not provided

Examples:
  rm.sh s3://my-bucket/file.txt
  rm.sh -e http://localhost:4566 s3://bucket/ --recursive
EOF
}

EP=""
if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  show_help
  exit 0
fi

if [[ ${1:-} == "-e" || ${1:-} == "--endpoint" ]]; then
  EP="$2"
  shift 2
fi

if [[ $# -lt 1 ]]; then
  echo "Error: target required"
  show_help
  exit 2
fi

EP=${EP:-http://localhost:4566}

# Provide safe defaults for LocalStack so the AWS CLI doesn't require `aws configure`.
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
export AWS_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION}}"

# If the first arg is a plain bucket/name, prefix with s3://
TARGET="$1"
shift || true
if [[ "$TARGET" != s3://* ]]; then
  TARGET="s3://$TARGET"
fi

# If no extra args and TARGET is a bare bucket (no path), remove bucket and all contents.
raw="${TARGET#s3://}"
raw_trim="${raw%/}"
if [[ $# -eq 0 ]]; then
  if [[ "$raw_trim" != */* ]]; then
    exec aws --endpoint-url "$EP" s3 rb "s3://$raw_trim" --force
  fi
fi

exec aws --endpoint-url "$EP" s3 rm "$TARGET" "$@"
