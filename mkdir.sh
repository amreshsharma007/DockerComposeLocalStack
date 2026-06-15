#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<EOF
Usage: mkdir.sh [-e ENDPOINT] bucket-name [aws-s3-args...]

Creates an S3 bucket using the AWS CLI with an optional --endpoint-url.

Environment:
  AWS_ENDPOINT_URL  default endpoint if -e not provided

Examples:
  mkdir.sh my-bucket
  mkdir.sh -e http://localhost:4566 my-bucket
  mkdir.sh s3://my-bucket
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

EP=${EP:-http://localhost:4566}

# Provide safe defaults for LocalStack so the AWS CLI doesn't require `aws configure`.
# These can be overridden by the environment or AWS config/profile.
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
export AWS_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION}}"

if [[ ${1:-} == "" ]]; then
  echo "Error: missing bucket name"
  show_help
  exit 1
fi

BUCKET_ARG="$1"
shift || true
if [[ "$BUCKET_ARG" == s3://* ]]; then
  TARGET="$BUCKET_ARG"
else
  TARGET="s3://$BUCKET_ARG"
fi

exec aws --endpoint-url "$EP" s3 mb "$TARGET" "$@"
