### Example Terraform Configuration for AWS Application Load Balancer (ALB)

#### Step 1: Create a Terraform Configuration File

Create a file named `main.tf` with the following Terraform configuration:

```hcl
provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

# Step 1: Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Step 2: Create Subnets
resource "aws_subnet" "my_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "my_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Step 3: Create a Security Group for EC2 Instances
resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Step 4: Create EC2 Instances
resource "aws_instance" "my_instance_1" {
  ami           = "ami-0c55b159cbfafe1f0"  # Change to your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet_1.id
  security_groups = [aws_security_group.my_sg.name]

  tags = {
    Name = "Instance1"
  }
}

resource "aws_instance" "my_instance_2" {
  ami           = "ami-0c55b159cbfafe1f0"  # Change to your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet_2.id
  security_groups = [aws_security_group.my_sg.name]

  tags = {
    Name = "Instance2"
  }
}

# Step 5: Create Target Group
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"

  vpc_id = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
  }
}

# Step 6: Register Targets
resource "aws_lb_target_group_attachment" "my_target_group_attachment_1" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.my_instance_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "my_target_group_attachment_2" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.my_instance_2.id
  port             = 80
}

# Step 7: Create Application Load Balancer
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_sg.id]

  subnets = [
    aws_subnet.my_subnet_1.id,
    aws_subnet.my_subnet_2.id,
  ]

  enable_deletion_protection = false

  tags = {
    Name = "MyALB"
  }
}

# Step 8: Create Listener
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}
```

### Step 2: Initialize and Apply Terraform

1. **Initialize Terraform**: Open a terminal and navigate to the directory containing your `main.tf` file. Run the following command:

   ```bash
   terraform init
   ```

2. **Plan the Deployment**: Check what resources Terraform will create by running:

   ```bash
   terraform plan
   ```

3. **Apply the Configuration**: Deploy the resources by executing:

   ```bash
   terraform apply
   ```

   Confirm the action by typing `yes` when prompted.

### Step 3: Accessing the Load Balancer

Once the deployment is complete, you can find the DNS name of the Application Load Balancer in the AWS Management Console under the EC2 > Load Balancers section. You can use this DNS name to access the services running on the EC2 instances through the ALB.

### Conclusion

This Terraform configuration sets up a basic AWS Application Load Balancer along with the necessary infrastructure components, including a VPC, subnets, security groups, EC2 instances, and target groups. You can modify the configurations as needed to fit your specific requirements, such as adjusting instance types, AMIs, or additional settings.