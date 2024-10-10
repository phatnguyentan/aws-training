provider "aws" {
  region = "us-east-1"  # Change this to your preferred region
}

# Create a KMS Key
resource "aws_kms_key" "example" {
  description = "KMS key for encrypting sensitive data"
}

# Create an S3 Bucket
resource "aws_s3_bucket" "customer_data" {
  bucket = "customer-data-bucket-unique-id"  # Change to a unique bucket name
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        kms_master_key_id = aws_kms_key.example.key_id
      }
    }
  }
}

# Create an RDS Instance
resource "aws_db_instance" "example" {
  identifier         = "financial-db-instance"
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.t3.micro"
  allocated_storage   = 20
  username           = "admin"
  password           = "yourpassword"  # Change this to a secure password
  db_name            = "financial_db"
  skip_final_snapshot = true
  storage_encrypted  = true
  kms_key_id        = aws_kms_key.example.key_id

  tags = {
    Name = "FinancialDB"
  }
}

# Create a Lambda Execution Role
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

# Attach Policies to Lambda Role
resource "aws_iam_policy_attachment" "lambda_kms_policy" {
  name       = "lambda_kms_policy"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "kms_policy" {
  name        = "KMSAccessPolicy"
  description = "Policy to allow Lambda to use KMS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.example.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_kms_policy" {
  policy_arn = aws_iam_policy.kms_policy.arn
  role       = aws_iam_role.lambda_role.name
}

# Create a Lambda Function
resource "aws_lambda_function" "data_processor" {
  function_name = "DataProcessor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"  # Change to your preferred runtime

  # Assuming you have a ZIP file ready for upload
  filename      = "data_processor.zip"  # Path to your Lambda deployment package
  source_code_hash = filebase64sha256("data_processor.zip")

  environment = {
    S3_BUCKET = aws_s3_bucket.customer_data.bucket
    KMS_KEY   = aws_kms_key.example.key_id
  }
}

# Outputs
output "kms_key_id" {
  value = aws_kms_key.example.key_id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.customer_data.bucket
}

output "rds_endpoint" {
  value = aws_db_instance.example.endpoint
}