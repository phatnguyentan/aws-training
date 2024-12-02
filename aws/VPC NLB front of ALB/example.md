Here’s a simple example of how to set up a Network Load Balancer (NLB) in front of an Application Load Balancer (ALB) using Terraform. This example assumes you have a basic understanding of Terraform and AWS.

### Terraform Configuration

```hcl
provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create Subnets
resource "aws_subnet" "my_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "my_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
}

# Create a Security Group for ALB
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a Security Group for NLB
resource "aws_security_group" "nlb_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the Application Load Balancer
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.my_subnet_1.id, aws_subnet.my_subnet_2.id]

  enable_deletion_protection = false
}

# Create the Network Load Balancer
resource "aws_lb" "my_nlb" {
  name               = "my-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.nlb_sg.id]
  subnets            = [aws_subnet.my_subnet_1.id, aws_subnet.my_subnet_2.id]

  enable_deletion_protection = false
}

# Create the Target Group for the ALB
resource "aws_lb_target_group" "my_alb_target_group" {
  name     = "my-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

# Create a Listener for the ALB
resource "aws_lb_listener" "my_alb_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_alb_target_group.arn
  }
}

# Create a Target Group for NLB
resource "aws_lb_target_group" "my_nlb_target_group" {
  name     = "my-nlb-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.my_vpc.id
}

# Create a Listener for the NLB
resource "aws_lb_listener" "my_nlb_listener" {
  load_balancer_arn = aws_lb.my_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_nlb_target_group.arn
  }
}
```

### Explanation

1. **VPC and Subnets**: Creates a VPC and two subnets across different availability zones.
2. **Security Groups**: Defines security groups for the ALB and NLB to allow inbound traffic on port 80.
3. **Load Balancers**: Creates both an Application Load Balancer (ALB) and a Network Load Balancer (NLB).
4. **Target Groups**: Sets up target groups for both the ALB and NLB.
5. **Listeners**: Configures listeners for both load balancers to forward traffic to their respective target groups.

### Steps to Deploy

1. Save the configuration in a file (e.g., `main.tf`).
2. Run `terraform init` to initialize the configuration.
3. Run `terraform apply` to create the resources.

Make sure to adjust the CIDR blocks, security settings, and any other configurations to fit your specific requirements.