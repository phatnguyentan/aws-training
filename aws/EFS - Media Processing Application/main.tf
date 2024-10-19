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

resource "aws_efs_file_system" "media" {
  creation_token = "media-efs"
  performance_mode = "generalPurpose" # Change if needed
}

resource "aws_efs_mount_target" "mount_a" {
  file_system_id = aws_efs_file_system.media.id
  subnet_id      = aws_subnet.subnet_a.id
}

resource "aws_efs_mount_target" "mount_b" {
  file_system_id = aws_efs_file_system.media.id
  subnet_id      = aws_subnet.subnet_b.id
}

resource "aws_instance" "media_processor_a" {
  ami                    = "ami-0c55b159cbfafe1f0" # Replace with an appropriate AMI
  instance_type         = "t2.micro"
  subnet_id             = aws_subnet.subnet_a.id
  security_groups       = [aws_security_group.allow_ssh.name]

  user_data = <<-EOF
              #!/bin/bash
              yum install -y amazon-efs-utils
              mkdir /mnt/media
              mount -t efs ${aws_efs_file_system.media.id}:/ /mnt/media
              EOF

  tags = {
    Name = "MediaProcessorA"
  }
}

resource "aws_instance" "media_processor_b" {
  ami                    = "ami-0c55b159cbfafe1f0" # Replace with an appropriate AMI
  instance_type         = "t2.micro"
  subnet_id             = aws_subnet.subnet_b.id
  security_groups       = [aws_security_group.allow_ssh.name]

  user_data = <<-EOF
              #!/bin/bash
              yum install -y amazon-efs-utils
              mkdir /mnt/media
              mount -t efs ${aws_efs_file_system.media.id}:/ /mnt/media
              EOF

  tags = {
    Name = "MediaProcessorB"
  }
}

output "efs_id" {
  value = aws_efs_file_system.media.id
}

output "instance_a_id" {
  value = aws_instance.media_processor_a.id
}

output "instance_b_id" {
  value = aws_instance.media_processor_b.id
}