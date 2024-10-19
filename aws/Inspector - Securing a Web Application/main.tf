provider "aws" {
  region = "us-west-2" # Change to your desired region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a" # Change as needed
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b" # Change as needed
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "subnet_a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet_b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "web_app" {
  ami                    = "ami-0c55b159cbfafe1f0" # Replace with an appropriate AMI
  instance_type         = "t2.micro"
  subnet_id             = aws_subnet.subnet_a.id
  security_groups       = [aws_security_group.allow_ssh.name]

  tags = {
    Name = "WebAppInstance"
  }
}

resource "aws_iam_role" "inspector_role" {
  name = "InspectorRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "inspector.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "inspector_role_policy" {
  role       = aws_iam_role.inspector_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonInspectorFullAccess"
}

resource "aws_inspector_assessment_target" "web_app_target" {
  name              = "WebAppAssessmentTarget"
  resource_group_arn = aws_inspector_resource_group.web_app_group.arn
}

resource "aws_inspector_resource_group" "web_app_group" {
  tags = {
    Name = "WebAppInstances"
  }
}

resource "aws_inspector_assessment_template" "web_app_template" {
  name                = "WebAppAssessmentTemplate"
  assessment_target_arn = aws_inspector_assessment_target.web_app_target.arn
  duration            = 3600 # Duration in seconds
  rules_package_arns  = [
    "arn:aws:inspector:us-west-2:aws:rulespackage/0-5ujw9u8g" # Change based on your needs
  ]
}

output "instance_id" {
  value = aws_instance.web_app.id
}

output "inspector_role_arn" {
  value = aws_iam_role.inspector_role.arn
}

output "assessment_template_id" {
  value = aws_inspector_assessment_template.web_app_template.id
}