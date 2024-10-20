provider "aws" {
  region = "us-west-2" # Change to your desired region
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (change based on your region)
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              # Update the package manager
              yum update -y
              
              # Install Apache web server
              yum install httpd -y
              
              # Start the Apache service
              systemctl start httpd
              systemctl enable httpd
              
              # Create a simple HTML page
              echo "<html><h1>Welcome to ABC Tech!</h1></html>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "WebServer"
  }
}

output "instance_ip" {
  value = aws_instance.web_server.public_ip
}