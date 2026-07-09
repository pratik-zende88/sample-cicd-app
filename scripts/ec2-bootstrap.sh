#!/bin/bash
# Run this ON THE EC2 INSTANCE (Ubuntu 22.04) to install everything needed:
# Docker, Jenkins, Git, AWS CLI
set -e

echo "=== Updating system ==="
sudo apt-get update -y
sudo apt-get upgrade -y

echo "=== Installing Git ==="
sudo apt-get install -y git

echo "=== Installing Docker ==="
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# allow ubuntu user to run docker without sudo
sudo usermod -aG docker ubuntu

echo "=== Installing Java (required for Jenkins) ==="
sudo apt-get install -y fontconfig openjdk-17-jre

echo "=== Installing Jenkins ==="
sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key -o /etc/apt/keyrings/jenkins-keyring.asc
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  "https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y jenkins

# allow jenkins user to run docker
sudo usermod -aG docker jenkins

echo "=== Installing AWS CLI v2 ==="
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt-get install -y unzip
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

echo "=== Restarting services ==="
sudo systemctl enable docker
sudo systemctl restart docker
sudo systemctl enable jenkins
sudo systemctl restart jenkins

echo ""
echo "======================================"
echo "  Setup complete!"
echo "  Docker version: $(docker --version)"
echo "  AWS CLI version: $(aws --version)"
echo "  Jenkins is starting... it will be ready at http://<EC2_PUBLIC_IP>:8080"
echo ""
echo "  IMPORTANT: log out and log back in (or run 'newgrp docker')"
echo "  for docker group permissions to apply to your user."
echo "======================================"
