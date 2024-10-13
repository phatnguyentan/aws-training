# Variables
REGION="us-east-1"
VPC_CIDR="10.0.0.0/16"
PUBLIC_SUBNET_CIDR="10.0.1.0/24"
PRIVATE_SUBNET_CIDR="10.0.2.0/24"
CUSTOMER_GATEWAY_IP="203.0.113.1"  # Change to your on-premises public IP
BGP_ASN="65000"                     # Change to your on-premises ASN

# Step 1: Create a VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --region $REGION --output text --query 'Vpc.VpcId')
echo "Created VPC: $VPC_ID"

# Step 2: Create a public subnet
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PUBLIC_SUBNET_CIDR --availability-zone "${REGION}a" --output text --query 'Subnet.SubnetId')
echo "Created Public Subnet: $PUBLIC_SUBNET_ID"

# Step 3: Create a private subnet
PRIVATE_SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PRIVATE_SUBNET_CIDR --availability-zone "${REGION}a" --output text --query 'Subnet.SubnetId')
echo "Created Private Subnet: $PRIVATE_SUBNET_ID"

# Step 4: Create a Customer Gateway
CUSTOMER_GATEWAY_ID=$(aws ec2 create-customer-gateway --type ipsec.1 --bgp-asn $BGP_ASN --public-ip $CUSTOMER_GATEWAY_IP --region $REGION --output text --query 'CustomerGateway.CustomerGatewayId')
echo "Created Customer Gateway: $CUSTOMER_GATEWAY_ID"

# Step 5: Create a Virtual Private Gateway
VPN_GATEWAY_ID=$(aws ec2 create-vpn-gateway --type ipsec.1 --region $REGION --output text --query 'VpnGateway.VpnGatewayId')
echo "Created Virtual Private Gateway: $VPN_GATEWAY_ID"

# Step 6: Attach the Virtual Private Gateway to the VPC
aws ec2 attach-vpn-gateway --vpn-gateway-id $VPN_GATEWAY_ID --vpc-id $VPC_ID --region $REGION
echo "Attached VPN Gateway to VPC"

# Step 7: Create the VPN Connection
VPN_CONNECTION_ID=$(aws ec2 create-vpn-connection --vpn-gateway-id $VPN_GATEWAY_ID --customer-gateway-id $CUSTOMER_GATEWAY_ID --type ipsec.1 --region $REGION --output text --query 'VpnConnection.VpnConnectionId')
echo "Created VPN Connection: $VPN_CONNECTION_ID"

# Optional: Output important information
echo "VPC ID: $VPC_ID"
echo "Public Subnet ID: $PUBLIC_SUBNET_ID"
echo "Private Subnet ID: $PRIVATE_SUBNET_ID"
echo "Customer Gateway ID: $CUSTOMER_GATEWAY_ID"
echo "VPN Gateway ID: $VPN_GATEWAY_ID"
echo "VPN Connection ID: $VPN_CONNECTION_ID"