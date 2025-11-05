# Kubernetes Deployment

## Deployment Steps

### 1. Update deployment.yaml
Replace: YOUR_DOCKERHUB_USERNAME/flask-aws-monitor:latest

### 2. Deploy
```bash
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### 3. Verify
```bash
kubectl get pods
kubectl get svc
```

### 4. Access
For Minikube:
```bash
minikube service flask-aws-monitor
```

For Cloud:
```bash
kubectl get svc flask-aws-monitor
```
