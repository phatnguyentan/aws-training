provider "aws" {
  region = "us-west-2"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Subnets
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2a"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# NAT Gateway
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Security Groups
resource "aws_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Kinesis Data Stream
resource "aws_kinesis_stream" "data_stream" {
  name             = "data-stream"
  shard_count      = 1
  retention_period = 24
}

# S3 Bucket for Raw Data
resource "aws_s3_bucket" "raw_data" {
  bucket = "raw-data-bucket"
  acl    = "private"
}

# Lambda Function for Real-Time Processing
resource "aws_lambda_function" "process_data" {
  function_name = "process_data"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  source_code_hash = filebase64sha256("lambda.zip")
  filename      = "lambda.zip"

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.processed_data.bucket
    }
  }
}

# S3 Bucket for Processed Data
resource "aws_s3_bucket" "processed_data" {
  bucket = "processed-data-bucket"
  acl    = "private"
}

# EMR Cluster for Batch Processing
resource "aws_emr_cluster" "emr_cluster" {
  name          = "emr-cluster"
  release_label = "emr-5.30.0"
  applications  = ["Hadoop", "Spark"]
  service_role  = aws_iam_role.emr_service_role.arn
  ec2_attributes {
    instance_profile = aws_iam_instance_profile.emr_instance_profile.arn
    subnet_id        = aws_subnet.private.id
  }
  master_instance_group {
    instance_type = "m5.xlarge"
  }
  core_instance_group {
    instance_type = "m5.xlarge"
    instance_count = 2
  }
}

# Glue Job for ETL
resource "aws_glue_job" "etl_job" {
  name     = "etl-job"
  role_arn     = aws_iam_role.glue_service_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://scripts/etl_script.py"
    python_version  = "3"
  }
  default_arguments = {
    "--TempDir" = "s3://temp/"
  }
}

# Redshift Cluster for Data Storage
resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier = "redshift-cluster"
  node_type          = "dc2.large"
  number_of_nodes    = 2
  master_username    = "admin"
  master_password    = "Password123"
  database_name      = "analyticsdb"
  iam_roles          = [aws_iam_role.redshift_service_role.arn]
}

# Athena for Data Analysis
resource "aws_athena_database" "athena_db" {
  name   = "analytics_db"
  bucket = aws_s3_bucket.processed_data.bucket
}

# QuickSight for Data Visualization
resource "aws_quicksight_user" "quicksight_user" {
  user_name     = "quicksight_user"
  email         = "user@example.com"
  identity_type = "IAM"
  user_role     = "READER"
  aws_account_id = data.aws_caller_identity.current.account_id
  namespace     = "default"
}

# IAM Roles and Policies
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "emr_service_role" {
  name = "emr_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "elasticmapreduce.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "emr_instance_profile" {
  name = "emr_instance_profile"
  role = aws_iam_role.emr_service_role.name
}

resource "aws_iam_role" "glue_service_role" {
  name = "glue_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "redshift_service_role" {
  name = "redshift_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      }
    ]
  })
}

# CloudWatch for Monitoring
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/process_data"
  retention_in_days = 14
}

# CloudTrail for Logging
resource "aws_cloudtrail" "main" {
  name                          = "main"
  s3_bucket_name                = aws_s3_bucket.raw_data.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}
