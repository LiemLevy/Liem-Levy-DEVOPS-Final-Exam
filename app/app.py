import os
import sys
import boto3
from flask import Flask, render_template_string
from botocore.exceptions import ClientError, NoCredentialsError

app = Flask(__name__)

# Fetch AWS credentials from environment variables
AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
REGION = os.getenv("AWS_REGION", "us-east-1")

# Validate credentials at startup
if not AWS_ACCESS_KEY or not AWS_SECRET_KEY:
    print("ERROR: AWS credentials not found!", file=sys.stderr)
    print("Please set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables.", file=sys.stderr)
    sys.exit(1)

print(f"✓ AWS credentials loaded")
print(f"✓ Using region: {REGION}")

# Initialize Boto3 clients
try:
    session = boto3.Session(
        aws_access_key_id=AWS_ACCESS_KEY,
        aws_secret_access_key=AWS_SECRET_KEY,
        region_name=REGION
    )
    
    ec2_client = session.client("ec2")
    elb_client = session.client("elbv2")
    print("✓ AWS clients initialized successfully")
except Exception as e:
    print(f"ERROR: Failed to initialize AWS clients: {e}", file=sys.stderr)
    sys.exit(1)

@app.route("/")
def home():
    try:
        # Fetch EC2 instances
        instances = ec2_client.describe_instances()
        instance_data = []
        for reservation in instances["Reservations"]:
            for instance in reservation["Instances"]:
                instance_data.append({
                    "ID": instance["InstanceId"],
                    "State": instance["State"]["Name"],
                    "Type": instance["InstanceType"],
                    "Public IP": instance.get("PublicIpAddress", "N/A")
                })

        # Fetch VPCs
        vpcs = ec2_client.describe_vpcs()
        vpc_data = [{"VPC ID": vpc["VpcId"], "CIDR": vpc["CidrBlock"]} for vpc in vpcs["Vpcs"]]

        # Fetch Load Balancers
        try:
            lbs = elb_client.describe_load_balancers()
            lb_data = [{"LB Name": lb["LoadBalancerName"], "DNS Name": lb["DNSName"]} for lb in lbs["LoadBalancers"]]
        except ClientError as e:
            if e.response['Error']['Code'] == 'AccessDenied':
                lb_data = [{"LB Name": "Access Denied", "DNS Name": "Check IAM permissions"}]
            else:
                raise

        # Fetch AMIs (only owned by the account)
        try:
            amis = ec2_client.describe_images(Owners=['self'])
            ami_data = [{"AMI ID": ami["ImageId"], "Name": ami.get("Name", "N/A")} for ami in amis["Images"][:10]]  # Limit to 10
            if not ami_data:
                ami_data = [{"AMI ID": "No AMIs found", "Name": "Create an AMI to see it here"}]
        except ClientError as e:
            if e.response['Error']['Code'] == 'AccessDenied':
                ami_data = [{"AMI ID": "Access Denied", "Name": "Check IAM permissions"}]
            else:
                raise

        # Render the result in a simple table
        html_template = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>AWS Resources Monitor</title>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body { 
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    min-height: 100vh;
                    padding: 20px;
                }
                .container {
                    max-width: 1200px;
                    margin: 0 auto;
                    background: white;
                    border-radius: 10px;
                    padding: 30px;
                    box-shadow: 0 10px 40px rgba(0,0,0,0.2);
                }
                h1 { 
                    color: #333; 
                    border-bottom: 3px solid #667eea; 
                    padding-bottom: 15px; 
                    margin-bottom: 20px;
                    font-size: 2em;
                }
                h2 {
                    color: #555;
                    margin-top: 30px;
                    margin-bottom: 15px;
                    font-size: 1.5em;
                    display: flex;
                    align-items: center;
                }
                h2::before {
                    content: "▶";
                    color: #667eea;
                    margin-right: 10px;
                }
                .status { 
                    background: #d4edda;
                    color: #155724;
                    padding: 10px 15px;
                    border-radius: 5px;
                    margin-bottom: 20px;
                    border-left: 4px solid #28a745;
                    font-weight: 500;
                }
                table { 
                    border-collapse: collapse; 
                    width: 100%; 
                    margin-bottom: 30px; 
                    background-color: white;
                    border-radius: 8px;
                    overflow: hidden;
                    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                }
                th, td { 
                    padding: 12px 15px; 
                    text-align: left;
                    border-bottom: 1px solid #e0e0e0;
                }
                th { 
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    font-weight: 600;
                    text-transform: uppercase;
                    font-size: 0.85em;
                    letter-spacing: 0.5px;
                }
                tr:last-child td {
                    border-bottom: none;
                }
                tr:hover {
                    background-color: #f8f9fa;
                }
                .empty-state {
                    text-align: center;
                    padding: 40px;
                    color: #999;
                    font-style: italic;
                }
                .footer {
                    margin-top: 30px;
                    padding-top: 20px;
                    border-top: 1px solid #e0e0e0;
                    text-align: center;
                    color: #999;
                    font-size: 0.9em;
                }
                .badge {
                    display: inline-block;
                    padding: 4px 8px;
                    border-radius: 12px;
                    font-size: 0.85em;
                    font-weight: 600;
                }
                .badge-running { background: #d4edda; color: #155724; }
                .badge-stopped { background: #f8d7da; color: #721c24; }
                @media (max-width: 768px) {
                    .container { padding: 15px; }
                    h1 { font-size: 1.5em; }
                    table { font-size: 0.9em; }
                    th, td { padding: 8px 10px; }
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🚀 AWS Resources Monitor</h1>
                <div class="status">
                    ✓ Connected to AWS Region: <strong>{{ region }}</strong>
                </div>
                
                <h2>EC2 Instances</h2>
                {% if instance_data %}
                <table>
                    <thead>
                        <tr>
                            <th>Instance ID</th>
                            <th>State</th>
                            <th>Type</th>
                            <th>Public IP</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for instance in instance_data %}
                        <tr>
                            <td><code>{{ instance['ID'] }}</code></td>
                            <td>
                                <span class="badge {% if instance['State'] == 'running' %}badge-running{% else %}badge-stopped{% endif %}">
                                    {{ instance['State'] }}
                                </span>
                            </td>
                            <td>{{ instance['Type'] }}</td>
                            <td>{{ instance['Public IP'] }}</td>
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>
                {% else %}
                <div class="empty-state">No EC2 instances found</div>
                {% endif %}

                <h2>Virtual Private Clouds (VPCs)</h2>
                {% if vpc_data %}
                <table>
                    <thead>
                        <tr>
                            <th>VPC ID</th>
                            <th>CIDR Block</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for vpc in vpc_data %}
                        <tr>
                            <td><code>{{ vpc['VPC ID'] }}</code></td>
                            <td>{{ vpc['CIDR'] }}</td>
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>
                {% else %}
                <div class="empty-state">No VPCs found</div>
                {% endif %}

                <h2>Load Balancers</h2>
                {% if lb_data %}
                <table>
                    <thead>
                        <tr>
                            <th>Load Balancer Name</th>
                            <th>DNS Name</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for lb in lb_data %}
                        <tr>
                            <td>{{ lb['LB Name'] }}</td>
                            <td><code>{{ lb['DNS Name'] }}</code></td>
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>
                {% else %}
                <div class="empty-state">No load balancers found</div>
                {% endif %}

                <h2>Amazon Machine Images (AMIs)</h2>
                {% if ami_data %}
                <table>
                    <thead>
                        <tr>
                            <th>AMI ID</th>
                            <th>Name</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for ami in ami_data %}
                        <tr>
                            <td><code>{{ ami['AMI ID'] }}</code></td>
                            <td>{{ ami['Name'] }}</td>
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>
                {% else %}
                <div class="empty-state">No AMIs found in your account</div>
                {% endif %}

                <div class="footer">
                    <p>🔄 Data refreshes on page reload | Built with Flask & AWS SDK (Boto3)</p>
                </div>
            </div>
        </body>
        </html>
        """

        return render_template_string(
            html_template, 
            instance_data=instance_data, 
            vpc_data=vpc_data,
            lb_data=lb_data, 
            ami_data=ami_data,
            region=REGION
        )
    
    except NoCredentialsError:
        error_html = """
        <html>
        <head><title>Error - No Credentials</title></head>
        <body style="font-family: Arial; padding: 40px; background-color: #f8d7da;">
            <div style="max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; border-left: 5px solid #dc3545;">
                <h1 style="color: #dc3545;">❌ AWS Credentials Not Found</h1>
                <p><strong>The application cannot find valid AWS credentials.</strong></p>
                <p>Please ensure you have set the following environment variables:</p>
                <ul>
                    <li><code>AWS_ACCESS_KEY_ID</code></li>
                    <li><code>AWS_SECRET_ACCESS_KEY</code></li>
                </ul>
                <p style="margin-top: 20px; padding: 15px; background: #f8f9fa; border-radius: 5px;">
                    <strong>💡 Tip:</strong> Check your config.env file and run ./setup.sh
                </p>
            </div>
        </body>
        </html>
        """
        return error_html, 500
    
    except ClientError as e:
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']
        
        error_html = f"""
        <html>
        <head><title>Error - AWS API Error</title></head>
        <body style="font-family: Arial; padding: 40px; background-color: #fff3cd;">
            <div style="max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; border-left: 5px solid #ffc107;">
                <h1 style="color: #856404;">⚠️ AWS API Error</h1>
                <p><strong>Error Code:</strong> {error_code}</p>
                <p><strong>Message:</strong> {error_message}</p>
                <p style="margin-top: 20px; padding: 15px; background: #f8f9fa; border-radius: 5px;">
                    <strong>💡 Common causes:</strong><br>
                    • Invalid AWS credentials<br>
                    • Insufficient IAM permissions<br>
                    • Wrong AWS region selected<br>
                    • Resource limits exceeded
                </p>
                <p style="margin-top: 15px;">
                    <strong>Current Region:</strong> {REGION}
                </p>
            </div>
        </body>
        </html>
        """
        return error_html, 500
    
    except Exception as e:
        error_html = f"""
        <html>
        <head><title>Error</title></head>
        <body style="font-family: Arial; padding: 40px; background-color: #f8d7da;">
            <div style="max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; border-left: 5px solid #dc3545;">
                <h1 style="color: #dc3545;">❌ Unexpected Error</h1>
                <p><strong>Error:</strong> {str(e)}</p>
                <p style="margin-top: 20px; padding: 15px; background: #f8f9fa; border-radius: 5px;">
                    Please check the application logs for more details.
                </p>
            </div>
        </body>
        </html>
        """
        return error_html, 500

@app.route("/health")
def health():
    """Health check endpoint for Kubernetes probes"""
    try:
        # Simple check to verify AWS connection
        ec2_client.describe_regions(MaxResults=1)
        return {"status": "healthy", "region": REGION, "service": "flask-aws-monitor"}, 200
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}, 500

@app.route("/info")
def info():
    """Information endpoint"""
    return {
        "service": "Flask AWS Monitor",
        "region": REGION,
        "version": "1.0.0",
        "endpoints": {
            "/": "Main dashboard",
            "/health": "Health check",
            "/info": "Service information"
        }
    }, 200

if __name__ == "__main__":
    print("=" * 50)
    print("🚀 Starting Flask AWS Monitor")
    print("=" * 50)
    print(f"📍 Region: {REGION}")
    print(f"🌐 Server: http://0.0.0.0:5001")
    print(f"❤️  Health: http://0.0.0.0:5001/health")
    print("=" * 50)
    app.run(host="0.0.0.0", port=5001, debug=True)
