# LocalStack Docker Compose Setup

This project contains a Docker Compose configuration for running LocalStack Community Edition, a fully functional local AWS cloud stack.

## Version

This setup uses **LocalStack Community Edition (free version)**. For Pro features, you'll need a license from [LocalStack](https://localstack.cloud/).

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. Start LocalStack:
   ```bash
   docker-compose up -d
   ```

2. Check the status:
   ```bash
   docker-compose ps
   ```

3. View logs:
   ```bash
   docker-compose logs -f
   ```

4. Stop LocalStack:
   ```bash
   docker-compose down
   ```

## Configuration

The Community Edition automatically detects and runs AWS services as you use them. You can customize the setup by:

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` to configure:
   - `DEBUG`: Enable debug logging (0 or 1)
   - `PERSISTENCE`: Keep LocalStack state across restarts (1 by default in this repo)

### Pro Version

If you have a LocalStack Pro license, update the docker-compose.yml:
- Change image to `localstack/localstack:latest` or `localstack/localstack-pro`
- Add environment variable: `LOCALSTACK_AUTH_TOKEN=your-token-here`
- Additional Pro features: persistence, advanced services, cloud pods, etc.

## Accessing LocalStack

LocalStack is accessible at:
- **Endpoint**: `http://localhost:4566`

## Example Usage

### Using AWS CLI

First, set these environment variables to avoid checksum errors:

```bash
export AWS_REQUEST_CHECKSUM_CALCULATION=when_required
export AWS_RESPONSE_CHECKSUM_VALIDATION=when_required
```

Configure AWS CLI to use LocalStack:

```bash
aws configure --profile localstack
# AWS Access Key ID: test
# AWS Secret Access Key: test
# Default region name: us-east-1
# Default output format: json
```

Create an S3 bucket:
```bash
aws --endpoint-url=http://localhost:4566 s3 mb s3://my-bucket --profile localstack
```

List S3 buckets:
```bash
aws --endpoint-url=http://localhost:4566 s3 ls --profile localstack
```

### Using awslocal

Install `awslocal` wrapper (optional but recommended):
```bash
pip install awscli-local
```

Then use `awslocal` instead of `aws`:
```bash
awslocal s3 mb s3://my-bucket
awslocal s3 ls
```

### S3: Upload / Download / Delete (LocalStack)

Use the commands below to upload, download, and delete objects from any S3 bucket running in LocalStack. Replace `BUCKET_NAME`, `OBJECT_KEY`, and local paths as needed. With the AWS CLI use the `--endpoint-url` flag; with `awslocal` the endpoint is implied.

Using AWS CLI:
```bash
# Upload a local file to a bucket
aws --endpoint-url=http://localhost:4566 s3 cp /path/to/local-file s3://BUCKET_NAME/OBJECT_KEY --profile localstack

# Download an object from a bucket to local path
aws --endpoint-url=http://localhost:4566 s3 cp s3://BUCKET_NAME/OBJECT_KEY /path/to/local-dest --profile localstack

# Delete a single object
aws --endpoint-url=http://localhost:4566 s3 rm s3://BUCKET_NAME/OBJECT_KEY --profile localstack

# Delete all objects in a bucket (recursive, irreversible)
aws --endpoint-url=http://localhost:4566 s3 rm s3://BUCKET_NAME --recursive --profile localstack
```

Using `awslocal` (simpler):
```bash
# Upload
awslocal s3 cp /path/to/local-file s3://BUCKET_NAME/OBJECT_KEY

# Download
awslocal s3 cp s3://BUCKET_NAME/OBJECT_KEY /path/to/local-dest

# Delete object
awslocal s3 rm s3://BUCKET_NAME/OBJECT_KEY

# Delete all objects in a bucket
awslocal s3 rm s3://BUCKET_NAME --recursive
```

Common services available in the free Community Edition:
- S3
- DynamoDB
- SQS
- SNS
- Lambda (basic)
- API Gateway (basic)
- CloudFormation (basic)
- And many more...

[See full coverage](https://docs.localstack.cloud/references/coverage/)

**Note**: Some advanced features require LocalStack Pro

## Data Persistence

This compose file enables persistence by default with `PERSISTENCE=1`, stores the state in `./volume` via the bind mount in `docker-compose.yml`, and saves snapshots on each mutating request so S3 buckets survive a reboot even if LocalStack does not shut down cleanly.

If you want to disable persistence temporarily, set `PERSISTENCE=0` in your `.env` file.

## Troubleshooting

- **Port conflicts**: Ensure port 4566 is not in use by another service
- **Docker socket**: The Docker socket is mounted to allow LocalStack to manage Lambda containers
- **Logs**: Check logs with `docker-compose logs localstack` for detailed error messages

## Bash scripts

This repository includes several small shell helper scripts in the project root to make common filesystem tasks easier during development. Inspect each script before running them.

- `cp.sh`: Lightweight wrapper for copying files. Usage: make executable and run `./cp.sh SOURCE DEST` or `bash cp.sh SOURCE DEST`.
- `mv.sh`: Move or rename files. Usage: `./mv.sh SOURCE DEST` or `bash mv.sh SOURCE DEST`.
- `rm.sh`: Remove files or directories. Use with caution. Usage: `./rm.sh TARGET` or `bash rm.sh TARGET`.
- `mkdir.sh`: Create directories (parents included). Usage: `./mkdir.sh DIRPATH` or `bash mkdir.sh DIRPATH`.
- `ll.sh`: Human-friendly long listing (wrapper around `ls -lh`); run as `./ll.sh [PATH]` or `bash ll.sh [PATH]`.

Quick tips:

- Make a script executable: `chmod +x ./cp.sh` (repeat for other scripts you want to run directly).
- Run with explicit shell if you prefer not to change permissions: `bash ./cp.sh args...`.
- Always review script contents before running, especially `rm.sh`.

