#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Configuration Verification Script${NC}"
echo -e "${BLUE}========================================${NC}\n"

ERRORS=0
WARNINGS=0

# Function to check file exists
check_file() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $description exists: $file"
        return 0
    else
        echo -e "${RED}✗${NC} $description missing: $file"
        ((ERRORS++))
        return 1
    fi
}

# Function to check if placeholder still exists in file
check_placeholder() {
    local file=$1
    local placeholder=$2
    local description=$3
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    if grep -q "$placeholder" "$file" 2>/dev/null; then
        echo -e "${YELLOW}⚠${NC} $description still contains placeholder '$placeholder' in: $file"
        ((WARNINGS++))
        return 1
    else
        echo -e "${GREEN}✓${NC} $description properly configured in: $file"
        return 0
    fi
}

# Check config.env
echo -e "\n${BLUE}Checking Configuration File:${NC}"
if check_file "config.env" "Config file"; then
    source config.env 2>/dev/null || true
    
    # Check for placeholders
    if [[ "$DOCKERHUB_USERNAME" == "your-"* ]]; then
        echo -e "${RED}✗${NC} DOCKERHUB_USERNAME not configured in config.env"
        ((ERRORS++))
    else
        echo -e "${GREEN}✓${NC} DOCKERHUB_USERNAME configured"
    fi
    
    if [[ "$AWS_ACCESS_KEY_ID" == "AKIAX"* ]] || [[ "$AWS_ACCESS_KEY_ID" == "your-"* ]]; then
        echo -e "${RED}✗${NC} AWS_ACCESS_KEY_ID not configured in config.env"
        ((ERRORS++))
    else
        echo -e "${GREEN}✓${NC} AWS_ACCESS_KEY_ID configured"
    fi
    
    if [[ "$AWS_SECRET_ACCESS_KEY" == *"your-"* ]] || [[ "$AWS_SECRET_ACCESS_KEY" == "Iwrl"* ]]; then
        echo -e "${RED}✗${NC} AWS_SECRET_ACCESS_KEY not configured in config.env"
        ((ERRORS++))
    else
        echo -e "${GREEN}✓${NC} AWS_SECRET_ACCESS_KEY configured"
    fi
else
    echo -e "${RED}✗${NC} config.env not found. Run: cp config.env.example config.env"
    ((ERRORS++))
fi

# Check application files
echo -e "\n${BLUE}Checking Application Files:${NC}"
check_file "app/app.py" "Flask application"
check_file "app/Dockerfile" "Dockerfile"
check_file "app/requirements.txt" "Requirements file"
check_file "docker-compose.yml" "Docker Compose file"

# Check Terraform files
echo -e "\n${BLUE}Checking Terraform Files:${NC}"
check_file "terraform/main.tf" "Terraform main"
check_file "terraform/variables.tf" "Terraform variables"
check_file "terraform/outputs.tf" "Terraform outputs"
check_file "terraform/user_data.sh" "User data script"

# Check Jenkins files
echo -e "\n${BLUE}Checking Jenkins Files:${NC}"
check_file "Jenkins/Jenkinsfile" "Jenkinsfile"
check_placeholder "Jenkins/Jenkinsfile" "YOUR_DOCKERHUB_USERNAME" "Jenkins pipeline"
check_placeholder "Jenkins/Jenkinsfile" "YOUR_USERNAME/YOUR_REPO" "Jenkins Git URL"

# Check Kubernetes files
echo -e "\n${BLUE}Checking Kubernetes Files:${NC}"
check_file "K8S/deployment.yaml" "K8S deployment"
check_file "K8S/service.yaml" "K8S service"
check_file "K8S/secret.yaml" "K8S secret"
check_placeholder "K8S/deployment.yaml" "YOUR_DOCKERHUB_USERNAME" "K8S deployment"

# Check Helm files
echo -e "\n${BLUE}Checking Helm Files:${NC}"
check_file "helm/flask-aws-monitor/Chart.yaml" "Helm Chart"
check_file "helm/flask-aws-monitor/values.yaml" "Helm values"
check_file "helm/flask-aws-monitor/templates/deployment.yaml" "Helm deployment template"
check_file "helm/flask-aws-monitor/templates/service.yaml" "Helm service template"
check_file "helm/flask-aws-monitor/templates/secret.yaml" "Helm secret template"
check_placeholder "helm/flask-aws-monitor/values.yaml" "YOUR_DOCKERHUB_USERNAME" "Helm values"

# Check helper scripts
echo -e "\n${BLUE}Checking Helper Scripts:${NC}"
check_file "setup.sh" "Setup script"
check_file ".gitignore" "Gitignore file"

if [ -f "setup.sh" ] && [ ! -x "setup.sh" ]; then
    echo -e "${YELLOW}⚠${NC} setup.sh is not executable. Run: chmod +x setup.sh"
    ((WARNINGS++))
fi

# Check if setup.sh has been run
echo -e "\n${BLUE}Checking If Setup Script Was Run:${NC}"
if [ -f "Jenkins/Jenkinsfile" ]; then
    if grep -q "YOUR_DOCKERHUB_USERNAME" "Jenkins/Jenkinsfile" 2>/dev/null; then
        echo -e "${RED}✗${NC} Setup script hasn't been run yet. Execute: ./setup.sh"
        ((ERRORS++))
    else
        echo -e "${GREEN}✓${NC} Setup script has been executed"
    fi
fi

# Check Docker
echo -e "\n${BLUE}Checking Docker Installation:${NC}"
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker is installed: $(docker --version)"
    if docker ps &> /dev/null; then
        echo -e "${GREEN}✓${NC} Docker daemon is running"
    else
        echo -e "${YELLOW}⚠${NC} Docker daemon is not running or insufficient permissions"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}⚠${NC} Docker is not installed"
    ((WARNINGS++))
fi

# Check Docker Compose
if command -v docker-compose &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker Compose is installed: $(docker-compose --version)"
else
    echo -e "${YELLOW}⚠${NC} Docker Compose is not installed"
    ((WARNINGS++))
fi

# Check Terraform
echo -e "\n${BLUE}Checking Terraform Installation:${NC}"
if command -v terraform &> /dev/null; then
    echo -e "${GREEN}✓${NC} Terraform is installed: $(terraform version | head -1)"
else
    echo -e "${YELLOW}⚠${NC} Terraform is not installed"
    ((WARNINGS++))
fi

# Check kubectl
echo -e "\n${BLUE}Checking kubectl Installation:${NC}"
if command -v kubectl &> /dev/null; then
    echo -e "${GREEN}✓${NC} kubectl is installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
else
    echo -e "${YELLOW}⚠${NC} kubectl is not installed"
    ((WARNINGS++))
fi

# Check Helm
echo -e "\n${BLUE}Checking Helm Installation:${NC}"
if command -v helm &> /dev/null; then
    echo -e "${GREEN}✓${NC} Helm is installed: $(helm version --short)"
else
    echo -e "${YELLOW}⚠${NC} Helm is not installed (optional)"
    ((WARNINGS++))
fi

# Check AWS CLI
echo -e "\n${BLUE}Checking AWS CLI:${NC}"
if command -v aws &> /dev/null; then
    echo -e "${GREEN}✓${NC} AWS CLI is installed: $(aws --version)"
else
    echo -e "${YELLOW}⚠${NC} AWS CLI is not installed (optional)"
fi

# Summary
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}          Verification Summary${NC}"
echo -e "${BLUE}========================================${NC}\n"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ Perfect! Everything is configured correctly!${NC}\n"
    echo -e "${YELLOW}Next Steps:${NC}"
    echo -e "  1. Test locally: ${GREEN}docker-compose up${NC}"
    echo -e "  2. Deploy infrastructure: ${GREEN}cd terraform && terraform apply${NC}"
    echo -e "  3. Deploy to Kubernetes: ${GREEN}helm install flask-monitor ./helm/flask-aws-monitor${NC}\n"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Configuration complete with $WARNINGS warning(s)${NC}"
    echo -e "You can proceed, but consider addressing the warnings.\n"
    exit 0
else
    echo -e "${RED}❌ Found $ERRORS error(s) and $WARNINGS warning(s)${NC}\n"
    echo -e "${YELLOW}Action Required:${NC}"
    
    if [ ! -f "config.env" ]; then
        echo -e "  1. ${GREEN}cp config.env.example config.env${NC}"
        echo -e "  2. Edit config.env with your credentials"
    fi
    
    if grep -q "YOUR_DOCKERHUB_USERNAME" Jenkins/Jenkinsfile 2>/dev/null; then
        echo -e "  3. ${GREEN}./setup.sh${NC} - Run the setup script"
    fi
    
    echo ""
    exit 1
fi
