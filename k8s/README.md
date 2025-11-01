## **6️⃣ Kubernetes Deployment YAML**  
**File:** `/k8s/README.md`

```markdown
# README for Kubernetes Deployment

## Objective
Deploy Flask container in Kubernetes cluster using Deployment & Service.

---

## Steps

1. Deployment
- Docker image from Docker Hub
- Container port 5001
- Replicas = 2

2. Service
- Type: LoadBalancer
- Port: 5001

3. Apply YAML
```bash
kubectl apply -f deployment.yaml
kubectl get pods,svc
Test

Browser: http://<EXTERNAL-IP>:5001

