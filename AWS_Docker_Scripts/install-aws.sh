#!/bin/bash

set -e

echo "Updating package list..."
apt-get update

echo "Installing dependencies..."
apt-get install -y curl unzip

echo "Downloading AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip

echo "Extracting..."
unzip -q awscliv2.zip

echo "Installing AWS CLI..."
./aws/install --update

echo
echo "AWS CLI installed successfully."
aws --version