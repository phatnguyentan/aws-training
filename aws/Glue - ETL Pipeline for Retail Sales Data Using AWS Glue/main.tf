provider "aws" {
  region = "us-west-2"  # Change to your desired region
}

# Create S3 buckets for raw and processed data
resource "aws_s3_bucket" "raw_sales_data" {
  bucket = "raw-sales-data-bucket-<unique_suffix>"  # Replace with a unique name
  acl    = "private"
}

resource "aws_s3_bucket" "processed_sales_data" {
  bucket = "processed-sales-data-bucket-<unique_suffix>"  # Replace with a unique name
  acl    = "private"
}

# Create IAM role for AWS Glue
resource "aws_iam_role" "glue_service_role" {
  name = "glue_service_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach policies to the Glue role
resource "aws_iam_role_policy_attachment" "glue_s3_access" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  role       = aws_iam_role.glue_service_role.name
}

resource "aws_iam_role_policy_attachment" "glue_s3_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.glue_service_role.name
}

# Create a Glue Crawler
resource "aws_glue_crawler" "sales_data_crawler" {
  name          = "sales-data-crawler"
  role          = aws_iam_role.glue_service_role.arn
  database_name = "retail_sales"

  s3_target {
    path = aws_s3_bucket.raw_sales_data.arn
  }

  table_prefix = "raw_"

  # Optional: Schedule the crawler
  # schedule {
  #   schedule_expression = "cron(0 12 * * ? *)"  # Daily at 12 PM UTC
  # }
}

# Create a Glue Job
resource "aws_glue_job" "sales_data_etl" {
  name               = "sales-data-etl"
  role               = aws_iam_role.glue_service_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.processed_sales_data.bucket}/scripts/sales_data_etl.py"  # Update with the actual script location
    python_version  = "3"
  }

  default_arguments = {
    "--TempDir"       = "s3://${aws_s3_bucket.processed_sales_data.bucket}/temp/"
    "--job-bookmark-option" = "job-bookmark-enable"
  }

  max_retries = 1
}

# Output the S3 bucket names
output "raw_sales_data_bucket" {
  value = aws_s3_bucket.raw_sales_data.bucket
}

output "processed_sales_data_bucket" {
  value = aws_s3_bucket.processed_sales_data.bucket
}