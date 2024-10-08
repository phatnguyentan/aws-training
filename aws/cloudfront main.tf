provider "aws" {
  region = "us-east-1"
}

# S3 Bucket for Static Assets
resource "aws_s3_bucket" "static_assets" {
  bucket = "your-ecommerce-static-assets"
  acl    = "public-read"

  versioning {
    enabled = true
  }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "ecommerce_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_assets.bucket_regional_domain_name
    origin_id   = "S3StaticAssets"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_access_identity.id
    }
  }

  origin {
    domain_name = "your-ec2-instance-public-dns.amazonaws.com" # Replace with your EC2 instance's public DNS
    origin_id   = "EC2Instance"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id = "S3StaticAssets"

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 3600
    default_ttl = 86400
    max_ttl     = 31536000
  }

  cache_behavior {
    path_pattern     = "/api/*"
    target_origin_id = "EC2Instance"

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  price_class = "PriceClass_100" # Change to PriceClass_200 or PriceClass_All for global coverage

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    # Alternatively, use ACM certificate for your domain
    # acm_certificate_arn = "your-acm-certificate-arn"
    # ssl_support_method = "sni-only"
  }

  tags = {
    Name = "EcommerceCloudFrontDistribution"
  }
}

# CloudFront Origin Access Identity for S3
resource "aws_cloudfront_origin_access_identity" "s3_access_identity" {
  comment = "Origin Access Identity for S3 Static Assets"
}

# S3 Bucket Policy to Allow CloudFront Access
resource "aws_s3_bucket_policy" "static_assets_policy" {
  bucket = aws_s3_bucket.static_assets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          "AWS" = aws_cloudfront_origin_access_identity.s3_access_identity.iam_arn
        }
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.static_assets.arn}/*"
      }
    ]
  })
}