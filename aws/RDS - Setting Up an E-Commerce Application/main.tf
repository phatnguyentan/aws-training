provider "aws" {
  region = "us-west-2" # Change to your preferred region
}

# Create a VPC
resource "aws_vpc" "ecommerce_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "ecommerce-vpc"
  }
}

# Create a subnet
resource "aws_subnet" "ecommerce_subnet" {
  vpc_id     = aws_vpc.ecommerce_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a" # Change as needed

  tags = {
    Name = "ecommerce-subnet"
  }
}

# Create a security group
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.ecommerce_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"] # Allow access from your application subnet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
  }

  tags = {
    Name = "rds-security-group"
  }
}

# Create an RDS instance
resource "aws_db_instance" "ecommerce_db" {
  identifier              = "ecommerce-db"
  engine                 = "mysql"
  engine_version         = "8.0" # Specify MySQL version
  instance_class         = "db.t3.micro" # Change as needed
  allocated_storage       = 20
  db_name                = "ecommerce"
  username               = "admin"
  password               = "YourStrongPassword123!" # Change this to a strong password
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.ecommerce_db_subnet_group.name

  tags = {
    Name = "ecommerce-db-instance"
  }
}

# Create a DB subnet group
resource "aws_db_subnet_group" "ecommerce_db_subnet_group" {
  name       = "ecommerce-db-subnet-group"
  subnet_ids = [aws_subnet.ecommerce_subnet.id]

  tags = {
    Name = "ecommerce-db-subnet-group"
  }
}

# Output the endpoint of the RDS instance
output "rds_endpoint" {
  value = aws_db_instance.ecommerce_db.endpoint
}