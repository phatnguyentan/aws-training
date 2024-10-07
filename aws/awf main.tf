provider "aws" {
  region = "us-west-2"  # Change to your desired region
}

# Create a WAF Web ACL
resource "aws_wafv2_web_acl" "ecommerce_web_acl" {
  name        = "ecommerce-web-acl"
  description = "Web ACL for E-commerce site"
  scope       = "CLOUDFRONT"  # Change to "REGIONAL" for ALB or API Gateway
  default_action {
    allow {}
  }

  visibility_config {
    cloud_watch_metrics_enabled = true
    metric_name                = "ecommerceWebAcl"
    sampled_requests_enabled    = true
  }

  rule {
    name     = "SQLInjectionRule"
    priority = 1
    action {
      block {}
    }

    statement {
      managed_rule_group_statement {
        name    = "AWSManagedRulesSQLiRuleSet"
        vendor  = "AWS"
      }
    }

    visibility_config {
      cloud_watch_metrics_enabled = true
      metric_name                = "SQLInjectionRule"
      sampled_requests_enabled    = true
    }
  }

  rule {
    name     = "XSSRule"
    priority = 2
    action {
      block {}
    }

    statement {
      managed_rule_group_statement {
        name    = "AWSManagedRulesXSSRuleSet"
        vendor  = "AWS"
      }
    }

    visibility_config {
      cloud_watch_metrics_enabled = true
      metric_name                = "XSSRule"
      sampled_requests_enabled    = true
    }
  }

  rule {
    name     = "IPBlocklistRule"
    priority = 3
    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blocked_ips.arn
      }
    }

    visibility_config {
      cloud_watch_metrics_enabled = true
      metric_name                = "IPBlocklistRule"
      sampled_requests_enabled    = true
    }
  }

  rule {
    name     = "RateLimitingRule"
    priority = 4
    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit                = 100
        aggregate_key_type   = "IP"
        scope_down_statement {
          byte_match_statement {
            search_string = "example.com"  # Adjust for your domain
            field_to_match {
              single_header {
                name = "Host"
              }
            }
            text_transformations {
              priority = 0
              type     = "NONE"
            }
          }
        }
      }
    }

    visibility_config {
      cloud_watch_metrics_enabled = true
      metric_name                = "RateLimitingRule"
      sampled_requests_enabled    = true
    }
  }
}

# Create an IP Set for blocked IPs
resource "aws_wafv2_ip_set" "blocked_ips" {
  name    = "blocked-ips"
  scope   = "CLOUDFRONT"  # Change to "REGIONAL" for ALB or API Gateway
  ip_address_version = "IPV4"

  addresses = [
    "192.0.2.0/24",  # Replace with actual IPs to block
    "203.0.113.0/24",
  ]

  visibility_config {
    cloud_watch_metrics_enabled = true
    metric_name                = "BlockedIPs"
    sampled_requests_enabled    = true
  }
}