# Jenkins CI/CD Pipeline

## Setup Instructions

### Install Jenkins on EC2
```bash
ssh -i builder_key.pem ec2-user@<EC2-IP>

sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
sudo yum install java-17-amazon-corretto -y
sudo yum install jenkins -y

sudo systemctl enable jenkins
sudo systemctl start jenkins

sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Access Jenkins
Open: http://<EC2-IP>:8080

### Configure Credentials
1. Jenkins → Manage Jenkins → Credentials
2. Add Secret Text: dockerhub-username
3. Add Secret Text: dockerhub-password

### Update Jenkinsfile
- IMAGE_NAME: your-dockerhub-username/flask-aws-monitor
- Git URL: your repository URL
