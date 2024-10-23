provider "aws" {
  region = "us-east-1"
}

# Create VPCs
resource "aws_vpc" "development" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Development VPC"
  }
}

resource "aws_vpc" "testing" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "Testing VPC"
  }
}

resource "aws_vpc" "production" {
  cidr_block = "10.2.0.0/16"
  tags = {
    Name = "Production VPC"
  }
}

# Create Transit Gateway
resource "aws_ec2_transit_gateway" "tg" {
  description = "Transit Gateway for VPCs"
  tags = {
    Name = "MyTransitGateway"
  }
}

# Attach VPCs to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "dev_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.tg.id
  vpc_id            = aws_vpc.development.id
  subnet_ids        = [aws_subnet.dev_subnet.id] # Define a valid subnet ID
}

resource "aws_ec2_transit_gateway_vpc_attachment" "test_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.tg.id
  vpc_id            = aws_vpc.testing.id
  subnet_ids        = [aws_subnet.test_subnet.id] # Define a valid subnet ID
}

resource "aws_ec2_transit_gateway_vpc_attachment" "prod_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.tg.id
  vpc_id            = aws_vpc.production.id
  subnet_ids        = [aws_subnet.prod_subnet.id] # Define a valid subnet ID
}

# Create Subnets for each VPC
resource "aws_subnet" "dev_subnet" {
  vpc_id            = aws_vpc.development.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "test_subnet" {
  vpc_id            = aws_vpc.testing.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "prod_subnet" {
  vpc_id            = aws_vpc.production.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "us-east-1a"
}

# Route Tables for Transit Gateway
resource "aws_ec2_transit_gateway_route_table" "tg_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.tg.id
  tags = {
    Name = "MyTGRouteTable"
  }
}

# Create routes in Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route" "dev_to_test" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_route_table.id
  destination_cidr_block         = "10.1.0.0/16"
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.dev_attachment.id
}

resource "aws_ec2_transit_gateway_route" "dev_to_prod" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_route_table.id
  destination_cidr_block         = "10.2.0.0/16"
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.dev_attachment.id
}

resource "aws_ec2_transit_gateway_route" "test_to_dev" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_route_table.id
  destination_cidr_block         = "10.0.0.0/16"
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.test_attachment.id
}

resource "aws_ec2_transit_gateway_route" "test_to_prod" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_route_table.id
  destination_cidr_block         = "10.2.0.0/16"
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.test_attachment.id
}

resource "aws_ec2_transit_gateway_route" "prod_to_dev" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_route_table.id
  destination_cidr_block         = "10.0.0.0/16"
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.prod_attachment.id
}

resource "aws_ec2_transit_gateway_route" "prod_to_test" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_route_table.id
  destination_cidr_block         = "10.1.0.0/16"
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.prod_attachment.id
}