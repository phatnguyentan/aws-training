provider "aws" {
  region = "us-west-2" # Change to your desired region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a" # Change as needed
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

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
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

resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Replace with an appropriate AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  security_groups = [aws_security_group.allow_ssh.name]

  tags = {
    Name = "AppServer"
  }
}

resource "aws_ebs_volume" "app_volume" {
  availability_zone = aws_subnet.main.availability_zone
  size             = 20 # Size in GiB
  type             = "gp3"

  tags = {
    Name = "AppVolume"
  }
}

resource "aws_ebs_volume" "db_volume" {
  availability_zone = aws_subnet.main.availability_zone
  size             = 30 # Size in GiB
  type             = "gp3"

  tags = {
    Name = "DBVolume"
  }
}

resource "aws_volume_attachment" "app_volume_attach" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.app_volume.id
  instance_id = aws_instance.app_server.id
}

resource "aws_volume_attachment" "db_volume_attach" {
  device_name = "/dev/sdi"
  volume_id   = aws_ebs_volume.db_volume.id
  instance_id = aws_instance.app_server.id
}

output "instance_id" {
  value = aws_instance.app_server.id
}

output "app_volume_id" {
  value = aws_ebs_volume.app_volume.id
}

output "db_volume_id" {
  value = aws_ebs_volume.db_volume.id
}