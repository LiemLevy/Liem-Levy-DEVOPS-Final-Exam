## **2️⃣ Terraform EC2 + Docker Setup**  
**File:** `/terraform/README.md`

```markdown
# README for Terraform EC2 + Docker Setup

## Objective
Provision an EC2 instance called "builder" with Docker installed.

---

## Steps

### EC2 Instance
- Name: `builder`
- Type: `t3.medium`
- AMI: Amazon Linux 2 or Ubuntu
- Public subnet, use VPC `vpc-044604d0bfb707142`

### SSH Key
- Terraform generates SSH key pair
- Outputs: private key path, key name, public IP

### Security Group
- Allow SSH (22) from your IP
- Allow HTTP (5001) from your IP
- Outbound: all

### Docker Installation (Manual)
SSH into EC2:
```bash
ssh -i builder_key.pem ubuntu@<public-ip>
sudo apt update
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker ubuntu
docker --version
docker compose version
Optional: Docker via Terraform remote-exec
Use remote-exec provisioner in Terraform