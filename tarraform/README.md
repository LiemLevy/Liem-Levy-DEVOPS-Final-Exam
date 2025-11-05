# Terraform Infrastructure Setup

## Description
This Terraform configuration provisions an EC2 instance named "builder" with Docker and Docker Compose installed.

## Prerequisites
- Terraform installed
- AWS CLI configured with credentials
- Access to VPC: vpc-044604d0bfb707142

## Usage

### Initialize Terraform
```bash
terraform init
```

### Plan the deployment
```bash
terraform plan
```

### Apply the configuration
```bash
terraform apply
```

### Get outputs
```bash
terraform output
terraform output -raw ssh_command
```

### Connect to the instance
```bash
chmod 400 builder_key.pem
ssh -i builder_key.pem ec2-user@<instance-public-ip>
```

### Destroy infrastructure
```bash
terraform destroy
```

## What's Provisioned
- EC2 instance (t3.medium) named "builder"
- Security group with ports 22, 5001, 8080 open
- SSH key pair (saved as builder_key.pem)
- Docker and Docker Compose installed via user_data

## Important Notes
- Private key is stored locally as `builder_key.pem`
- Change security group CIDR blocks to your IP for better security
- Instance is in a public subnet for external access
