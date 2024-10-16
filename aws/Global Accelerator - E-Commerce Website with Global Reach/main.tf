provider "aws" {
  region = "us-east-1"  # Primary region (e.g., N. Virginia)
}

# Create Global Accelerator
resource "aws_global_accelerator" "example" {
  name     = "shopglobal-accelerator"
  enabled  = true

  ip_address_type = "IPV4"

  # Optional: Configure the accelerator to use your own custom domain
  # dns_name = "your.custom.domain"
}

# Create Listener for the Global Accelerator
resource "aws_global_accelerator_listener" "example" {
  accelerator_arn = aws_global_accelerator.example.id
  port_range {
    from_port = 80  # HTTP
    to_port   = 80
  }
  protocol = "TCP"
}

# Create Health Check Configuration
resource "aws_global_accelerator_health_check" "example" {
  health_check_interval_seconds = 30
  health_check_path             = "/"
  health_check_port             = 80
  health_check_protocol         = "TCP"
  health_check_timeout_seconds   = 5
  healthy_threshold_count       = 2
  unhealthy_threshold_count     = 2
}

# Create Endpoint Group for US East
resource "aws_global_accelerator_endpoint_group" "us_east" {
  listener_arn = aws_global_accelerator_listener.example.id
  accelerator_arn = aws_global_accelerator.example.id
  endpoint_group_region = "us-east-1"

  # Add the endpoint (Load Balancer, EC2 Instance, etc.)
  endpoint_configuration {
    endpoint_id = "your-us-east-load-balancer-id"  # Replace with your Load Balancer ID
    weight      = 128
  }

  health_check_interval_seconds = aws_global_accelerator_health_check.example.health_check_interval_seconds
  health_check_path = aws_global_accelerator_health_check.example.health_check_path
  health_check_port = aws_global_accelerator_health_check.example.health_check_port
  health_check_protocol = aws_global_accelerator_health_check.example.health_check_protocol
}

# Create Endpoint Group for EU (Ireland)
resource "aws_global_accelerator_endpoint_group" "eu" {
  listener_arn = aws_global_accelerator_listener.example.id
  accelerator_arn = aws_global_accelerator.example.id
  endpoint_group_region = "eu-west-1"  # Ireland

  # Add the endpoint (Load Balancer, EC2 Instance, etc.)
  endpoint_configuration {
    endpoint_id = "your-eu-load-balancer-id"  # Replace with your Load Balancer ID
    weight      = 128
  }

  health_check_interval_seconds = aws_global_accelerator_health_check.example.health_check_interval_seconds
  health_check_path = aws_global_accelerator_health_check.example.health_check_path
  health_check_port = aws_global_accelerator_health_check.example.health_check_port
  health_check_protocol = aws_global_accelerator_health_check.example.health_check_protocol
}