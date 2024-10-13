Sure! Below is an AWS CLI script that sets up an EC2 instance, creates a custom AMI from it, and launches additional instances using that AMI.

### AWS CLI Script for Managing AMIs

```bash
#!/bin/bash

# Variables
REGION="us-west-2"  # Change to your preferred region
KEY_NAME="MyKeyPair"  # Change to your key pair name
AMI_ID="ami-0c55b159cbfafe1f0"  # Replace with the desired base AMI
SECURITY_GROUP_NAME="web_sg"
INSTANCE_TYPE="t2.micro"
INSTANCE_COUNT=2  # Number of additional instances to launch

# Create a key pair (if it doesn't exist)
aws ec2 create-key-pair --key-name "$KEY_NAME" --query "KeyMaterial" --output text > "$KEY_NAME.pem"
chmod 400 "$KEY_NAME.pem"

# Create a security group
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name "$SECURITY_GROUP_NAME" --description "Allow HTTP and SSH traffic" --query "GroupId" --output text)

# Allow SSH and HTTP traffic
aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0

# Launch an EC2 instance
INSTANCE_ID=$(aws ec2 run-instances --image-id "$AMI_ID" --count 1 --instance-type "$INSTANCE_TYPE" --key-name "$KEY_NAME" --security-group-ids "$SECURITY_GROUP_ID" --query "Instances[0].InstanceId" --output text)

echo "Launched EC2 instance: $INSTANCE_ID"

# Wait for the instance to be running
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

# Create a custom AMI from the EC2 instance
CUSTOM_AMI_ID=$(aws ec2 create-image --instance-id "$INSTANCE_ID" --name "MyCustomAMI" --no-reboot --query "ImageId" --output text)

echo "Created custom AMI: $CUSTOM_AMI_ID"

# Launch additional instances using the custom AMI
aws ec2 run-instances --image-id "$CUSTOM_AMI_ID" --count "$INSTANCE_COUNT" --instance-type "$INSTANCE_TYPE" --key-name "$KEY_NAME" --security-group-ids "$SECURITY_GROUP_ID"

echo "Launched $INSTANCE_COUNT additional instances using AMI: $CUSTOM_AMI_ID"

# Output the public IPs of the instances
aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].PublicIpAddress" --output text
aws ec2 describe-instances --filters "Name=image-id,Values=$CUSTOM_AMI_ID" --query "Reservations[*].Instances[*].PublicIpAddress" --output text
```

### Explanation of the Script

1. **Variables**: Set the AWS region, key pair name, base AMI ID, security group name, instance type, and the number of additional instances to launch.

2. **Create Key Pair**: Creates an SSH key pair for accessing the EC2 instances and saves it to a `.pem` file.

3. **Create Security Group**: Creates a security group that allows SSH (port 22) and HTTP (port 80) traffic.

4. **Launch EC2 Instance**: Launches an EC2 instance using the specified base AMI.

5. **Wait for Instance to be Running**: Uses `wait` to pause the script until the instance is in the running state.

6. **Create Custom AMI**: Creates a custom AMI from the launched EC2 instance without rebooting it.

7. **Launch Additional Instances**: Launches additional EC2 instances using the custom AMI.

8. **Output Public IPs**: Displays the public IPs of the launched instances.

### Usage

1. **Make the Script Executable**:
   ```bash
   chmod +x setup_ami.sh
   ```

2. **Run the Script**:
   ```bash
   ./setup_ami.sh
   ```

### Note

- Ensure you have the necessary IAM permissions to execute these commands.
- Update the AMI ID to a valid AMI for your region.
- The script creates a new key pair; if you already have one, you can modify the script to use the existing key pair.
- The security group allows traffic from anywhere (0.0.0.0/0). Adjust this according to your security requirements.

This AWS CLI script automates the process of launching EC2 instances, creating custom AMIs, and launching additional instances from those AMIs, ensuring a streamlined workflow for managing your infrastructure.