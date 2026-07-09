#!/bin/bash
# Step 4: Create an Amazon ECR repository (one-time setup)
# Run this once from your local machine or AWS CloudShell (needs AWS CLI configured)

set -e

AWS_REGION="ap-south-1"       # change to your region
ECR_REPO_NAME="sample-app"

echo "Creating ECR repository: $ECR_REPO_NAME in $AWS_REGION..."

aws ecr create-repository \
    --repository-name "$ECR_REPO_NAME" \
    --region "$AWS_REGION" \
    --image-scanning-configuration scanOnPush=true \
    --image-tag-mutability MUTABLE

echo "Done. Repository URI:"
aws ecr describe-repositories \
    --repository-names "$ECR_REPO_NAME" \
    --region "$AWS_REGION" \
    --query 'repositories[0].repositoryUri' \
    --output text

# --- Manual push example (Jenkins does this automatically) ---
# aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin <account_id>.dkr.ecr.$AWS_REGION.amazonaws.com
# docker tag sample-app:latest <account_id>.dkr.ecr.$AWS_REGION.amazonaws.com/sample-app:latest
# docker push <account_id>.dkr.ecr.$AWS_REGION.amazonaws.com/sample-app:latest
