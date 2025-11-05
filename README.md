# Flask AWS Monitor Application

## Bug Fixes Applied
The original code had missing API calls for:
1. VPCs - Added ec2_client.describe_vpcs()
2. Load Balancers - Added elb_client.describe_load_balancers()
3. AMIs - Added ec2_client.describe_images(Owners=['self'])

## Local Development
```bash
cd app
pip install -r requirements.txt
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
python app.py
```

## Docker Build and Run
```bash
docker build -t flask-aws-monitor:latest .
docker run -d -p 5001:5001 -e AWS_ACCESS_KEY_ID="key" -e AWS_SECRET_ACCESS_KEY="secret" flask-aws-monitor:latest
```
