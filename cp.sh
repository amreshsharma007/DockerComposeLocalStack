#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<EOF
Usage: cp.sh [-e ENDPOINT] <source> <destination> [aws-cp-opts...]

Runs: aws s3 cp with optional --endpoint-url.

Environment:
  AWS_ENDPOINT_URL  default endpoint if -e not provided

Examples:
  cp.sh s3://my-bucket/file.txt ./
  cp.sh -e http://localhost:4566 s3://bucket/ ./ --recursive
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

if [[ $# -lt 2 ]]; then
  echo "Error: source and destination required"
  show_help
  exit 2
fi

EP=${EP:-http://localhost:4566}

exec aws --endpoint-url "$EP" s3 cp "$@"
