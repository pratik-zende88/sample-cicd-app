#!/bin/bash
# Step 5 (Option 1): Manual deploy to EC2 - for reference / one-off testing.
# In the real pipeline, Jenkins runs the equivalent commands over SSH automatically.

set -e

AWS_REGION="ap-south-1"
ECR_REGISTRY="<account_id>.dkr.ecr.${AWS_REGION}.amazonaws.com"
ECR_REPO_NAME="sample-app"
CONTAINER_NAME="sample-app"

echo "Logging in to ECR..."
aws ecr get-login-password --region "$AWS_REGION" | \
    docker login --username AWS --password-stdin "$ECR_REGISTRY"

echo "Pulling latest image..."
docker pull "${ECR_REGISTRY}/${ECR_REPO_NAME}:latest"

echo "Stopping old container (if running)..."
docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

echo "Starting new container..."
docker run -d \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    -p 80:3000 \
    "${ECR_REGISTRY}/${ECR_REPO_NAME}:latest"

echo "Deployed. Check: curl http://localhost/health"
