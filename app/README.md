## **4️⃣ Debugging Flask Application Bug**  
**File:** `/app/README-debug.md` (or same `/app/README.md` appended)

```markdown
# README for Debugging Flask Application

## Objective
Fix bug that prevents listing AWS VPCs, Load Balancers, and AMIs.

---

## Steps

1. Fix `app.py`
```python
ec2 = boto3.client('ec2', region_name='us-east-1')
vpcs = ec2.describe_vpcs()
# Repeat for Load Balancers and AMIs
Build Docker Image

bash
Copy code
docker build -t flask-app:fixed .
Run Container

bash
Copy code
docker run -d -p 5001:5001 flask-app:fixed
Test in browser: http://<EC2-IP>:5001

Commit & Push

bash
Copy code
git add .
git commit -m "Fixed Flask bug"
git push origin feature/fix-bug
