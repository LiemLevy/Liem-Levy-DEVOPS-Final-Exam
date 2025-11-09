# Flask AWS Monitor Helm Chart

## Installation

### 1. Update values.yaml
Change: YOUR_DOCKERHUB_USERNAME/flask-aws-monitor

### 2. Install
```bash
cd helm
helm install flask-monitor ./flask-aws-monitor
```

### 3. Verify
```bash
helm list
kubectl get pods
kubectl get svc
```

### 4. Access
```bash
kubectl get svc flask-monitor-flask-aws-monitor
```

## Ingress Bonus Feature
When ingress.enabled is true, service type automatically changes to ClusterIP.
When ingress.enabled is false, service type is LoadBalancer.

## Upgrade
```bash
helm upgrade flask-monitor ./flask-aws-monitor
```

## Uninstall
```bash
helm uninstall flask-monitor
```

