# End-to-End DevOps Project

## Project Overview
This project demonstrates end-to-end DevOps practices including:
- Infrastructure as Code with Terraform
- Containerization with Docker
- Kubernetes deployment with Helm
- CI/CD with Jenkins
- AWS resource monitoring Flask application

## Project Structure
```
.
├── terraform/              # Infrastructure provisioning
├── app/                    # Flask application source code
├── helm/                   # Helm charts for K8s deployment
├── jenkins/                # Jenkins pipeline configuration
└── k8s/                    # Kubernetes manifests
```

## Setup Instructions
1. Clone this repository
2. Follow each folder's README for specific setup instructions
3. Ensure you have AWS credentials configured
4. Use the provided Git workflow (feature → dev → main)

## Git Workflow
- Work in feature branches
- Merge to `dev` first
- After validation, merge `dev` to `main`
- No direct pushes to `main`

## Author
Liem Levy
