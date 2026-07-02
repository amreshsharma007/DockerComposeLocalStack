#!/bin/bash

set -e

ENDPOINT="${1:-http://host.docker.internal:4566}"

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

echo "========================================="
echo "Testing LocalStack S3"
echo "Endpoint : $ENDPOINT"
echo "========================================="
echo

echo "Checking LocalStack health..."
curl -s "$ENDPOINT/_localstack/health"
echo
echo

echo "Listing buckets..."
aws --endpoint-url="$ENDPOINT" s3 ls

echo
echo "S3 test completed successfully."