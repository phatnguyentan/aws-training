provider "aws" {
  region = "us-west-2"  # Change to your preferred region
}

# Create a key pair for SSH access
resource "aws_key_pair" "my_key" {
  key_name   = "MyKeyPair"
  public_key = file("~/.ssh/id_rsa.pub")  # Update the path to your public key
}

# Create a security group
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change as needed for your security
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change as needed for your security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 instance
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with your desired base AMI
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "WebServer"
  }
}

# Create a custom AMI from the EC2 instance
resource "aws_ami_from_instance" "web_server_ami" {
  name               = "MyCustomAMI"
  source_instance_id = aws_instance.web_server.id
  no_reboot          = true  # Do not reboot the instance during AMI creation

  tags = {
    Name = "MyCustomAMI"
  }
}

# Launch additional instances using the custom AMI
resource "aws_instance" "additional_web_servers" {
  count         = 2  # Number of additional instances to launch
  ami           = aws_ami_from_instance.web_server_ami.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "AdditionalWebServer-${count.index + 1}"
  }
}

# Output the AMI ID and instance details
output "custom_ami_id" {
  value = aws_ami_from_instance.web_server_ami.id
}

output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "additional_web_servers_ips" {
  value = aws_instance.additional_web_servers[*].public_ip
}