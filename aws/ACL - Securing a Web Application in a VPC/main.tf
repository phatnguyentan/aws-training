provider "aws" {
  region = "us-east-1" # Change to your desired AWS region
}

# Create a VPC
resource "aws_vpc" "web_app_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "WebAppVPC"
  }
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.web_app_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

# Create a Network ACL
resource "aws_network_acl" "web_app_acl" {
  vpc_id = aws_vpc.web_app_vpc.id

  egress {
    rule_no    = 100
    protocol   = "-1"  # All traffic
    rule_action = "allow"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 100
    protocol   = "6"    # TCP
    rule_action = "allow"
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 200
    protocol   = "6"    # TCP
    rule_action = "allow"
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 300
    protocol   = "-1"   # All traffic
    rule_action = "deny"
    cidr_block = "0.0.0.0/0"
  }

  # Additional rule to allow SSH from corporate IP
  ingress {
    rule_no    = 400
    protocol   = "6"    # TCP
    rule_action = "allow"
    from_port  = 22
    to_port    = 22
    cidr_block = "203.0.113.0/24"  # Replace with your corporate IP range
  }

  tags = {
    Name = "WebAppACL"
  }
}

# Associate the ACL with the public subnet
resource "aws_network_acl_association" "public_subnet_acl_association" {
  subnet_id      = aws_subnet.public_subnet.id
  network_acl_id = aws_network_acl.web_app_acl.id
}

output "vpc_id" {
  value = aws_vpc.web_app_vpc.id
}

output "subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "acl_id" {
  value = aws_network_acl.web_app_acl.id
}