provider "aws" {
  region = "us-west-2"  # Change to your desired region
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds_security_group"
  description = "Allow access to RDS instance"
  
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change to your specific IP range for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Instance
resource "aws_db_instance" "postgres" {
  identifier              = "shop-smart-db"
  engine                 = "postgres"
  engine_version         = "14.6"  # Specify your desired version
  instance_class         = "db.t3.micro"  # Change based on your requirements
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type           = "gp2"  # General Purpose SSD
  username               = "admin"
  password               = "YourSecurePassword!"  # Use a secure method for passwords
  db_name                = "shopsmart_db"
  skip_final_snapshot    = true
  multi_az               = true
  publicly_accessible     = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "ShopSmartPostgresDB"
  }
}

# Outputs
output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "db_instance_id" {
  value = aws_db_instance.postgres.id
}