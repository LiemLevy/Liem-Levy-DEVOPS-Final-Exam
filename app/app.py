from flask import Flask
import boto3

app = Flask(__name__)

@app.route('/')
def index():
    ec2 = boto3.client('ec2', region_name='us-east-1')
    vpcs = ec2.describe_vpcs()
    return f"VPCs: {len(vpcs['Vpcs'])}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
