provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

# Create a Virtual Private Cloud (VPC)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MainVPC"
  }
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "PublicSubnet"
  }
}

# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "PrivateSubnet"
  }
}

# Create a Customer Gateway
resource "aws_customer_gateway" "on_prem" {
  bgp_asn    = 65000            # Change to your on-premises ASN
  ip_address = "203.0.113.1"    # Change to your on-premises public IP
  type       = "ipsec.1"

  tags = {
    Name = "OnPremCustomerGateway"
  }
}

# Create a Virtual Private Gateway
resource "aws_virtual_private_gateway" "vpn_gateway" {
  tags = {
    Name = "MainVPNGateway"
  }
}

# Attach the Virtual Private Gateway to the VPC
resource "aws_vpn_gateway_attachment" "vpn_attachment" {
  vpc_id             = aws_vpc.main.id
  vpn_gateway_id     = aws_virtual_private_gateway.vpn_gateway.id
}

# Create the VPN Connection
resource "aws_vpn_connection" "vpn_connection" {
  vpn_gateway_id      = aws_virtual_private_gateway.vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.on_prem.id
  type                = "ipsec.1"

  # Optional: BGP configuration
  static_routes_only = false

  tags = {
    Name = "MainVPNConnection"
  }
}

# Output important information
output "vpn_connection_id" {
  value = aws_vpn_connection.vpn_connection.id
}

output "vpn_gateway_id" {
  value = aws_virtual_private_gateway.vpn_gateway.id
}

output "customer_gateway_id" {
  value = aws_customer_gateway.on_prem.id
}