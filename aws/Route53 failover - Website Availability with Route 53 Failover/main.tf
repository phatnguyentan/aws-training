provider "aws" {
  region = "us-east-1"  # Change as necessary
}

resource "aws_route53_zone" "example" {
  name = "example.com"
}

resource "aws_instance" "primary" {
  ami           = "ami-12345678"  # Replace with your AMI ID
  instance_type = "t2.micro"

  tags = {
    Name = "Primary Instance"
  }
}

resource "aws_instance" "backup" {
  ami           = "ami-12345678"  # Replace with your AMI ID
  instance_type = "t2.micro"

  tags = {
    Name = "Backup Instance"
  }
}

resource "aws_route53_record" "primary_record" {
  zone_id = aws_route53_zone.example.id
  name     = "www.example.com"
  type     = "A"
  alias {
    name                   = aws_instance.primary.public_ip
    zone_id                = aws_instance.primary.id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.primary_health_check.id
  set_identifier   = "Primary"
  failover_routing_policy {
    type = "PRIMARY"
  }
}

resource "aws_route53_record" "backup_record" {
  zone_id = aws_route53_zone.example.id
  name     = "www.example.com"
  type     = "A"
  alias {
    name                   = aws_instance.backup.public_ip
    zone_id                = aws_instance.backup.id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.primary_health_check.id
  set_identifier   = "Backup"
  failover_routing_policy {
    type = "SECONDARY"
  }
}

resource "aws_route53_health_check" "primary_health_check" {
  fqdn              = "www.example.com"
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "Primary Health Check"
  }
}