### AWS CLI Script for AWS Shield Scenario

```bash
#!/bin/bash

# Variables
REGION="us-west-2"  # Change to your preferred region
VPC_ID="vpc-abc123"  # Change to your VPC ID
SUBNET_ID_1="subnet-abc123"  # Change to your first subnet ID
SUBNET_ID_2="subnet-def456"  # Change to your second subnet ID
SG_NAME="app_sg"
LB_NAME="app_lb"
WEB_ACL_NAME="my_web_acl"

# Create a Security Group for the Load Balancer
aws ec2 create-security-group --group-name "$SG_NAME" --description "Security group for the application load balancer" --vpc-id "$VPC_ID"

# Get the Security Group ID
SG_ID=$(aws ec2 describe-security-groups --group-names "$SG_NAME" --query "SecurityGroups[0].GroupId" --output text)

# Allow HTTP traffic
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0

# Create Application Load Balancer
LB_ARN=$(aws elbv2 create-load-balancer --name "$LB_NAME" --subnets "$SUBNET_ID_1" "$SUBNET_ID_2" --security-groups "$SG_ID" --query "LoadBalancers[0].LoadBalancerArn" --output text)

# Create a Web ACL for WAF
WEB_ACL_ARN=$(aws wafv2 create-web-acl --name "$WEB_ACL_NAME" --scope REGIONAL --default-action Allow={} --description "Web ACL for DDoS protection" --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName="$WEB_ACL_NAME" --query "Summary.WebACLArn" --output text)

# Create a Rate Limit Rule
RULE_ID=$(aws wafv2 create-rule --name "RateLimitRule" --scope REGIONAL --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName="RateLimit" --action Block={} --statement '{
    "RateBasedStatement": {
        "Limit": 1000,
        "AggregateKeyType": "IP"
    }
}' --query "Summary.Id" --output text)

# Associate the Rule with the Web ACL
aws wafv2 update-web-acl --name "$WEB_ACL_NAME" --scope REGIONAL --id "$WEB_ACL_ARN" --default-action Allow={} --rules "{
    \"Action\": { \"Block\": {} },
    \"Name\": \"RateLimitRule\",
    \"Priority\": 1,
    \"Statement\": { \"RateBasedStatement\": { \"Limit\": 1000, \"AggregateKeyType\": \"IP\" }},
    \"VisibilityConfig\": { \"SampledRequestsEnabled\": true, \"CloudWatchMetricsEnabled\": true, \"MetricName\": \"RateLimit\" }
}" --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName="$WEB_ACL_NAME"

# Associate the Web ACL with the Load Balancer
aws wafv2 associate-web-acl --web-acl-arn "$WEB_ACL_ARN" --resource-arn "$LB_ARN"

# Enable Shield Advanced for the Load Balancer
aws shield create-protection --name "my-shield-protection" --resource-arn "$LB_ARN"

echo "Setup complete! Load Balancer ARN: $LB_ARN"
```

### Explanation of the CLI Script

1. **Variables**: Replace the placeholders for region, VPC ID, subnet IDs, and security group names with your actual values.

2. **Create Security Group**: A security group is created to allow HTTP traffic to the Application Load Balancer.

3. **Create Load Balancer**: An Application Load Balancer is created with the specified subnets and security group.

4. **Create Web ACL**: A new AWS WAF Web ACL is created with a default allow action.

5. **Create Rate Limit Rule**: A rate limit rule is created to block excessive requests from a single IP.

6. **Associate Web ACL**: The Web ACL is associated with the Application Load Balancer.

7. **Enable Shield Advanced**: AWS Shield Advanced protection is enabled for the Load Balancer.

### Usage

1. **Make the Script Executable**:
   ```bash
   chmod +x setup_aws_shield.sh
   ```

2. **Run the Script**:
   ```bash
   ./setup_aws_shield.sh
   ```

### Note

- Ensure you have the necessary IAM permissions to execute these commands, including permissions for EC2, ELB, WAF, and Shield.
- The script may need adjustments based on your specific architecture and requirements.