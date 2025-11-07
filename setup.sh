#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  DevOps Project Configuration Setup${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${BLUE}Note: This script assumes you've already cloned your repository${NC}"
echo -e "${BLUE}      It will only update configuration files with your credentials${NC}\n"

# Check if config.env exists
if [ ! -f "config.env" ]; then
    echo -e "${RED}ERROR: config.env file not found!${NC}"
    echo -e "${YELLOW}Creating config.env from template...${NC}"
    if [ -f "config.env.example" ]; then
        cp config.env.example config.env
        echo -e "${YELLOW}Please edit config.env with your actual credentials and run this script again.${NC}"
    else
        echo -e "${RED}Template file not found. Please create config.env manually.${NC}"
    fi
    exit 1
fi

# Load environment variables
set -a
source config.env
set +a

# Validate required variables
REQUIRED_VARS=("DOCKERHUB_USERNAME" "GITHUB_USERNAME" "GITHUB_REPO" "AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY")

echo -e "${BLUE}Validating configuration...${NC}"
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ] || [ "${!var}" == "your-"* ]; then
        echo -e "${RED}ERROR: $var is not properly set in config.env${NC}"
        echo -e "${YELLOW}Please update config.env with your actual values.${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✓ Configuration validated successfully${NC}\n"

# Function to replace placeholders in a file
replace_placeholders() {
    local file=$1
    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}⚠ File not found: $file (skipping)${NC}"
        return
    fi
    
    echo -e "${BLUE}→ Updating: $file${NC}"
    
    # Create backup
    cp "$file" "${file}.bak"
    
    # Replace all placeholders
    sed -i "s|YOUR_DOCKERHUB_USERNAME|${DOCKERHUB_USERNAME}|g" "$file"
    sed -i "s|YOUR_USERNAME|${GITHUB_USERNAME}|g" "$file"
    sed -i "s|YOUR_REPO|${GITHUB_REPO}|g" "$file"
    sed -i "s|your-dockerhub-username|${DOCKERHUB_USERNAME}|g" "$file"
    sed -i "s|your-github-username|${GITHUB_USERNAME}|g" "$file"
    sed -i "s|your-repo-name|${GITHUB_REPO}|g" "$file"
    sed -i "s|AKIAXLEKZJVVSTPGSZ6O|${AWS_ACCESS_KEY_ID}|g" "$file"
    sed -i "s|IwrlmVWb4I6FTWorvqu+4qF5M9jIyqndbXfgb3HX|${AWS_SECRET_ACCESS_KEY}|g" "$file"
    sed -i "s|vpc-044604d0bfb707142|${VPC_ID}|g" "$file"
    sed -i "s|ami-0c02fb55267c0f8b3|${AMI_ID}|g" "$file"
    sed -i "s|t3\.medium|${INSTANCE_TYPE}|g" "$file"
    sed -i "s|us-east-1|${AWS_REGION}|g" "$file"
    
    echo -e "${GREEN}  ✓ Updated successfully${NC}"
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Updating Jenkins Configuration${NC}"
echo -e "${BLUE}========================================${NC}"

# Update Jenkinsfile
# NOTE: The Jenkinsfile already has the Git clone step
# It will clone from YOUR GitHub repo when the pipeline runs
# You don't need to clone manually - Jenkins does this automatically!
replace_placeholders "Jenkins/Jenkinsfile"

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Updating Kubernetes Manifests${NC}"
echo -e "${BLUE}========================================${NC}"

# Update Kubernetes files (note: handling both K8S and k8s directories)
if [ -d "K8S" ]; then
    replace_placeholders "K8S/deployment.yaml"
    replace_placeholders "K8S/secret.yaml"
elif [ -d "k8s" ]; then
    replace_placeholders "k8s/deployment.yaml"
    replace_placeholders "k8s/secret.yaml"
fi

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Updating Helm Charts${NC}"
echo -e "${BLUE}========================================${NC}"

# Update Helm values
replace_placeholders "helm/flask-aws-monitor/values.yaml"
replace_placeholders "helm/flask-aws-monitor/Chart.yaml"

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Updating Terraform Configuration${NC}"
echo -e "${BLUE}========================================${NC}"

# Update Terraform files (note: handling both terraform and tarraform directories)
if [ -d "terraform" ]; then
    replace_placeholders "terraform/variables.tf"
    replace_placeholders "terraform/main.tf"
elif [ -d "tarraform" ]; then
    replace_placeholders "tarraform/variables.tf"
    replace_placeholders "tarraform/main.tf"
fi

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Creating Local Environment Files${NC}"
echo -e "${BLUE}========================================${NC}"

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
    build: 
      context: ./app
      dockerfile: Dockerfile
    ports:
      - "5001:5001"
    environment:
      - AWS_ACCESS_KEY_ID=\${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=\${AWS_SECRET_ACCESS_KEY}
      - AWS_REGION=\${AWS_REGION}
    env_file:
      - ./app/.env
    container_name: flask-aws-monitor
    restart: unless-stopped
EOF
echo -e "${GREEN}✓ Created docker-compose.yml${NC}"

# Create/update .gitignore
if [ ! -f ".gitignore" ]; then
    echo -e "${BLUE}→ Creating .gitignore${NC}"
else
    echo -e "${BLUE}→ Updating .gitignore${NC}"
fi

cat > .gitignore << EOF
# Credentials and secrets
config.env
app/.env
*.pem
*.key

# Backup files
*.bak
*.backup

# Python
__pycache__/
*.py[cod]
*\$py.class
*.so
.Python
env/
venv/
.venv
ENV/

# Terraform
.terraform/
*.tfstate
*.tfstate.*
.terraform.lock.hcl

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Docker
.dockerignore
EOF
echo -e "${GREEN}✓ .gitignore updated${NC}"

# Create deployment helper script
cat > deploy-local.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting Flask AWS Monitor locally..."
docker-compose up --build
EOF
chmod +x deploy-local.sh
echo -e "${GREEN}✓ Created deploy-local.sh${NC}"

# Create cleanup script
cat > cleanup.sh << 'EOF'
#!/bin/bash
echo "🧹 Cleaning up generated files and backups..."
find . -name "*.bak" -delete
docker-compose down 2>/dev/null
echo "✓ Cleanup complete"
EOF
chmod +x cleanup.sh
echo -e "${GREEN}✓ Created cleanup.sh${NC}"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  Configuration Complete! ✨${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${YELLOW}📋 Summary of Changes:${NC}"
echo -e "  ${GREEN}✓${NC} Jenkins pipeline configured"
echo -e "  ${GREEN}✓${NC} Kubernetes manifests updated"
echo -e "  ${GREEN}✓${NC} Helm charts configured"
echo -e "  ${GREEN}✓${NC} Terraform variables set"
echo -e "  ${GREEN}✓${NC} Local environment created"
echo -e "  ${GREEN}✓${NC} Helper scripts generated\n"

echo -e "${YELLOW}🚀 Next Steps:${NC}"
echo -e "  ${BLUE}1.${NC} Test locally:"
echo -e "     ${GREEN}./deploy-local.sh${NC} or ${GREEN}docker-compose up${NC}"
echo -e "\n  ${BLUE}2.${NC} Deploy infrastructure:"
echo -e "     ${GREEN}cd terraform && terraform init && terraform apply${NC}"
echo -e "\n  ${BLUE}3.${NC} Setup Jenkins:"
echo -e "     - SSH to EC2: ${GREEN}ssh -i builder_key.pem ec2-user@<EC2-IP>${NC}"
echo -e "     - Follow: ${GREEN}Jenkins/README.md${NC}"
echo -e "\n  ${BLUE}4.${NC} Deploy to Kubernetes:"
echo -e "     ${GREEN}helm install flask-monitor ./helm/flask-aws-monitor${NC}"
echo -e "     OR"
echo -e "     ${GREEN}kubectl apply -f K8S/${NC}\n"

echo -e "${YELLOW}📝 Git Workflow:${NC}"
echo -e "  ${BLUE}1.${NC} Stage your changes:"
echo -e "     ${GREEN}git add .${NC}"
echo -e "  ${BLUE}2.${NC} Commit your changes:"
echo -e "     ${GREEN}git commit -m \"Configure project with credentials\"${NC}"
echo -e "  ${BLUE}3.${NC} Push to your repo:"
echo -e "     ${GREEN}git push origin dev${NC}"
echo -e "     (or whatever branch you're on)\n"

echo -e "${RED}⚠️  Security Reminders:${NC}"
echo -e "  ${RED}•${NC} Backup files (*.bak) were created - review before deleting"
echo -e "  ${RED}•${NC} config.env and app/.env are in .gitignore"
echo -e "  ${RED}•${NC} ${YELLOW}NEVER push config.env to GitHub!${NC}"
echo -e "  ${RED}•${NC} Use IAM roles in production instead of access keys"
echo -e "  ${RED}•${NC} Run ${GREEN}./cleanup.sh${NC} to remove backup files\n"

echo -e "${BLUE}📌 Important Note:${NC}"
echo -e "  Jenkins will automatically clone your GitHub repository when the pipeline runs."
echo -e "  You don't need to clone it manually on the EC2 instance.\n"

# Optional: Show what would be committed
if command -v git &> /dev/null; then
    if [ -d .git ]; then
        echo -e "${YELLOW}📦 Modified files (ready for git add):${NC}"
        git status --short 2>/dev/null | head -10
        echo ""
    fi
fi

echo -e "${GREEN}✨ Setup complete! Happy deploying! 🎉${NC}\n"
