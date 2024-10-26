provider "aws" {
  region = "us-west-2"  # Change to your desired region
}

# Create a VPC
resource "aws_vpc" "refined_zone_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.refined_zone_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.refined_zone_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2a"
}

# Create refined zone subnet
resource "aws_subnet" "refined_zone_subnet" {
  vpc_id            = aws_vpc.refined_zone_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2a"
}

# Create a security group for the refined zone
resource "aws_security_group" "refined_zone_sg" {
  vpc_id = aws_vpc.refined_zone_vpc.id
  name   = "refined_zone_sg"

  ingress {
    from_port   = 5432  # Allow access to RDS
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Allow access from within the VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow outbound traffic
  }
}

# Create an S3 bucket for sensitive data
resource "aws_s3_bucket" "sensitive_data_bucket" {
  bucket = "sensitive-data-bucket-<unique_suffix>"  # Replace with a unique name
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Create an RDS instance
resource "aws_db_instance" "example" {
  identifier         = "refined-zone-db"
  engine             = "postgres"
  engine_version     = "13.5"
  instance_class     = "db.t3.micro"  # Choose an appropriate instance class
  allocated_storage   = 20
  storage_encrypted  = true
  db_subnet_group_name = aws_db_subnet_group.refined_zone_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.refined_zone_sg.id]
  username           = "db_admin"
  password           = "P@ssword123"  # Use a more secure method for managing passwords
  skip_final_snapshot = true
}

# Create a subnet group for RDS
resource "aws_db_subnet_group" "refined_zone_db_subnet_group" {
  name       = "refined-zone-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.refined_zone_subnet.id]

  tags = {
    Name = "Refined Zone DB Subnet Group"
  }
}

output "vpc_id" {
  value = aws_vpc.refined_zone_vpc.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.sensitive_data_bucket.bucket
}

output "rds_endpoint" {
  value = aws_db_instance.example.endpoint
}