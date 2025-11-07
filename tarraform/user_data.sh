#!/bin/bash
set -e

# Log output to file for debugging
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "================================"
echo "Starting Builder Instance Setup"
echo "================================"

# Update system
echo "Updating system packages..."
yum update -y

# Install Docker
echo "Installing Docker..."
yum install -y docker
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
echo "Adding ec2-user to docker group..."
usermod -aG docker ec2-user

# Install Docker Compose
echo "Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install Git
echo "Installing Git..."
yum install -y git

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/
ln -sf /usr/local/bin/kubectl /usr/bin/kubectl

# Install Helm
echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installations
echo "================================"
echo "Verifying installations..."
echo "================================"
docker --version
docker-compose --version
git --version
kubectl version --client
helm version

echo "================================"
echo "Builder Instance Setup Complete!"
echo "================================"
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker-compose --version)"
echo "Git: $(git --version)"
echo "kubectl: $(kubectl version --client --short)"
echo "Helm: $(helm version --short)"
echo "================================"
