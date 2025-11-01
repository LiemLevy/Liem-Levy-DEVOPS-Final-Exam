## **5️⃣ Jenkins CI/CD Pipeline**  
**File:** `/ci_cd/README.md`

```markdown
# README for Jenkins CI/CD Pipeline

## Objective
Extend Jenkinsfile: linting, security scan, Docker build, push to Docker Hub.

---

## Steps

### Pipeline Requirements
- Parallel:
  - Linting: Flake8, ShellCheck, Hadolint
  - Security scan: Trivy, Bandit
- Build & Push Docker image
- Clone Git repo

### Running Jenkins Pipeline
- EC2 builder node with Docker
- Verify:
  - Linting passed
  - Security scan passed
  - Docker image pushed

### Mock Commands
```groovy
sh 'echo "Linting passed"'
sh 'echo "Security scan passed"'
Real Commands (Bonus)
bash
Copy code
flake8 app/
bandit -r app/
hadolint Dockerfile
trivy image flask-app:latest