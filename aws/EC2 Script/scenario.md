#!/bin/bash

# Variables
INSTANCE_TYPE="t2.micro"
KEY_NAME="your-key-pair"          # Replace with your key pair name
SECURITY_GROUP="your-security-group" # Replace with your security group name
AMI_ID="ami-0abcdef1234567890"    # Replace with a valid AMI ID (e.g., Amazon Linux 2)
REGION="us-west-2"                # Replace with your desired AWS region
TAG_NAME="NodeAppServer"           # Tag for the instance
GIT_REPO="https://github.com/user/repo.git"  # Replace with your Git repository URL

# Step 1: Launch an EC2 instance
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME --security-groups $SECURITY_GROUP --query 'Instances[0].InstanceId' --output text --region $REGION)

echo "Launched EC2 Instance: $INSTANCE_ID"

# Step 2: Wait for the instance to be in running state
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION
echo "Instance is now running."

# Step 3: Get the public IP address of the instance
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text --region $REGION)
echo "Public IP: $PUBLIC_IP"

# Step 4: Install Node.js and npm
ssh -o StrictHostKeyChecking=no -i "$KEY_NAME.pem" ec2-user@$PUBLIC_IP << 'EOF'
    sudo yum update -y
    curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
    sudo yum install -y nodejs
EOF

# Step 5: Clone the Git repository and start the application
ssh -o StrictHostKeyChecking=no -i "$KEY_NAME.pem" ec2-user@$PUBLIC_IP << 'EOF'
    git clone $GIT_REPO ~/my-node-app
    cd ~/my-node-app
    npm install
    nohup node app.js > output.log 2>&1 &
    echo "Node.js application started."
EOF

echo "Deployment complete. Access your application at http://$PUBLIC_IP:3000"  # Adjust port as needed