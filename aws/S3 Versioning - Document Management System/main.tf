# Main Terraform configuration file

provider "aws" {
  region = "us-east-1" # Change to your desired region
}

resource "aws_s3_bucket" "company_documents" {
  bucket = "company-documents-unique-name" # Change to a unique bucket name

  versioning {
    enabled = true
  }

  # Optional: Add a lifecycle rule to manage old versions
  lifecycle_rule {
    id      = "manage-old-versions"
    enabled = true

    noncurrent_version_expiration {
      days = 30 # Change to desired number of days
    }
  }
}

# Optionally, you can define a bucket policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.company_documents.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.company_documents.arn}/*"
      }
    ]
  })
}