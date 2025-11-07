#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  DevOps Project Configuration Setup${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Check if config.env exists
if [ ! -f "config.env" ]; then
    echo -e "${RED}ERROR: config.env file not found!${NC}"
    echo "Please create config.env file with your credentials."
    exit 1
fi

# Load environment variables
source config.env

# Validate required variables
REQUIRED_VARS=("DOCKERHUB_USERNAME" "GITHUB_USERNAME" "GITHUB_REPO" "AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY")

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo -e "${RED}ERROR: $var is not set in config.env${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✓ Configuration file loaded successfully${NC}\n"

# Function to replace placeholders in a file
replace_placeholders() {
    local file=$1
    echo -e "${YELLOW}Updating: $file${NC}"
    
    sed -i.bak "s|YOUR_DOCKERHUB_USERNAME|${DOCKERHUB_USERNAME}|g" "$file"
    sed -i.bak "s|YOUR_USERNAME|${GITHUB_USERNAME}|g" "$file"
    sed -i.bak "s|YOUR_REPO|${GITHUB_REPO}|g" "$file"
    sed -i.bak "s|AKIAXLEKZJVVSTPGSZ6O|${AWS_ACCESS_KEY_ID}|g" "$file"
    sed -i.bak "s|IwrlmVWb4I6FTWorvqu+4qF5M9jIyqndbXfgb3HX|${AWS_SECRET_ACCESS_KEY}|g" "$file"
    
    rm "${file}.bak" 2>/dev/null || true
}

# Update Jenkinsfile
if [ -f "Jenkins/Jenkinsfile" ]; then
    replace_placeholders "Jenkins/Jenkinsfile"
    echo -e "${GREEN}✓ Jenkins/Jenkinsfile updated${NC}"
fi

# Update Kubernetes deployment
if [ -f "K8S/deployment.yaml" ]; then
    replace_placeholders "K8S/deployment.yaml"
    echo -e "${GREEN}✓ K8S/deployment.yaml updated${NC}"
fi

# Update Kubernetes secret
if [ -f "K8S/secret.yaml" ]; then
    replace_placeholders "K8S/secret.yaml"
    echo -e "${GREEN}✓ K8S/secret.yaml updated${NC}"
fi

# Update Helm values
if [ -f "helm/flask-aws-monitor/values.yaml" ]; then
    replace_placeholders "helm/flask-aws-monitor/values.yaml"
    echo -e "${GREEN}✓ helm/flask-aws-monitor/values.yaml updated${NC}"
fi

# Update app Dockerfile if needed
if [ -f "app/Dockerfile" ]; then
    echo -e "${GREEN}✓ app/Dockerfile verified${NC}"
fi

# Create .env file for local Docker testing
cat > app/.env << EOF
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
AWS_REGION=${AWS_REGION}
EOF
echo -e "${GREEN}✓ Created app/.env for local testing${NC}"

# Create docker-compose.yml for easy local testing
cat > docker-compose.yml << EOF
version: '3.8'

services:
  flask-app:
    build: ./app
    ports:
      - "5001:5001"
    env_file:
      - ./app/.env
    container_name: flask-aws-monitor
EOF
echo -e "${GREEN}✓ Created docker-compose.yml${NC}"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  Configuration Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${YELLOW}Next Steps:${NC}"
echo -e "1. Test locally: ${GREEN}docker-compose up${NC}"
echo -e "2. Deploy infrastructure: ${GREEN}cd terraform && terraform apply${NC}"
echo -e "3. Setup Jenkins on EC2 and configure credentials"
echo -e "4. Deploy to Kubernetes: ${GREEN}helm install flask-monitor ./helm/flask-aws-monitor${NC}"
echo -e "\n${YELLOW}Security Reminder:${NC}"
echo -e "${RED}⚠ Add config.env and app/.env to .gitignore!${NC}"
echo -e "${RED}⚠ Never commit credentials to Git!${NC}\n"
