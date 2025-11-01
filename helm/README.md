## **7️⃣ Helm Chart Deployment**  
**File:** `/helm/README.md`

```markdown
# README for Helm Chart Deployment

## Objective
Package Flask deployment as Helm chart for Kubernetes.

---

## Steps

### Install Helm
```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
Deploy Chart
bash
Copy code
helm install flask-monitor ./flask-aws-monitor
kubectl get pods,svc
Test
Browser: http://<EXTERNAL-IP>:5001

Update & Rollback
bash
Copy code
helm upgrade flask-monitor ./flask-aws-monitor
helm rollback flask-monitor <revision>
Ingress (Optional)
In values.yaml:

yaml
Copy code
ingress:
  enabled: true
If ingress = true → ServiceType = ClusterIP

If ingress = false → ServiceType = LoadBalancer