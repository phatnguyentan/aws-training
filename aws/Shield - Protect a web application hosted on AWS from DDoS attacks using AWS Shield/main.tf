provider "aws" {
  region = "us-west-2"  # Change to your preferred region
}

# Create a Security Group for the Load Balancer
resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Security group for the application load balancer"

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

# Create Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_sg.id]
  subnets            = ["subnet-abc123", "subnet-def456"]  # Change to your subnets

  enable_deletion_protection = false

  tags = {
    Name = "app-lb"
  }
}

# Create a Web ACL for WAF
resource "aws_wafv2_web_acl" "web_acl" {
  name        = "my_web_acl"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }

  rule {
    name     = "RateLimitRule"
    priority = 1

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"

        scope_down_statement {
          byte_match_statement {
            search_string = "bad-bot"
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            positional_constraint = "CONTAINS"
          }
        }
      }
    }

    action {
      block {}
    }

    visibility_config {
      sampled_requests_enabled = true
      cloud_watch_metrics_enabled = true
      metric_name = "RateLimit"
    }
  }

  visibility_config {
    cloud_watch_metrics_enabled = true
    metric_name                = "WebACL"
    sampled_requests_enabled    = true
  }
}

# Associate the Web ACL with the Load Balancer
resource "aws_wafv2_web_acl_association" "web_acl_association" {
  resource_arn = aws_lb.app_lb.arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl.arn
}

# Enable Shield Advanced for the Load Balancer
resource "aws_shield_protection" "shield_protection" {
  name = "my-shield-protection"
  resource_arn = aws_lb.app_lb.arn
}

output "load_balancer_dns_name" {
  value = aws_lb.app_lb.dns_name
}