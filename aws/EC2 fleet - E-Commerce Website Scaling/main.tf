provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

resource "aws_ec2_fleet" "ecommerce_fleet" {
  launch_template {
    id      = aws_launch_template.ecommerce_template.id
    version = "$Latest"
  }

  target_capacity_specification {
    total_target_capacity = 50  # Total number of instances
    on_demand_target_capacity = 20  # Number of On-Demand instances
    spot_target_capacity = 30  # Number of Spot instances
    default_target_capacity_type = "spot"
  }

  # Specify the instance types and their weights
  instance_type {
    instance_type = "t3.medium"
    weighted_capacity = 1
  }

  instance_type {
    instance_type = "c5.large"
    weighted_capacity = 2
  }

  # Use the lowest price allocation strategy
  allocation_strategy = "lowestPrice"

  # Optional: Add tags for organization
  tags = {
    Name = "EcommerceFleet"
  }
}

resource "aws_launch_template" "ecommerce_template" {
  name_prefix   = "ecommerce-"
  image_id      = "ami-0c55b159cbfafe1f0"  # Example AMI ID, change as needed
  instance_type = "t3.medium"

  key_name = "your-key-name"  # Specify your key pair name

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = "subnet-0bb1c79de3EXAMPLE"  # Change to your subnet ID
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "fleet_id" {
  value = aws_ec2_fleet.ecommerce_fleet.id
}