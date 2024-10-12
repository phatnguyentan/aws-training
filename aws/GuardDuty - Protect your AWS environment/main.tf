provider "aws" {
  region = "us-west-2"  # Change to your preferred region
}

# Enable CloudTrail
resource "aws_cloudtrail" "main" {
  name                          = "my-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
}

# Create S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "my-cloudtrail-logs-unique-id"  # Ensure this bucket name is globally unique
}

# Enable GuardDuty
resource "aws_guardduty_detector" "main" {
  enable = true
}

# Create SNS topic for GuardDuty alerts
resource "aws_sns_topic" "guardduty_alerts" {
  name = "GuardDutyAlerts"
}

# Subscribe email to the SNS topic (Replace with your email)
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.guardduty_alerts.arn
  protocol  = "email"
  endpoint  = "your_email@example.com"  # Change to your email
}

# Create VPC Flow Logs
resource "aws_flow_log" "vpc_flow_log" {
  log_group_name = aws_cloudwatch_log_group.vpc_log_group.name
  vpc_id         = aws_vpc.main.id
  traffic_type   = "ALL"
  iam_role_arn   = aws_iam_role.vpc_flow_log_role.arn
}

# Create CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_log_group" {
  name = "vpc-flow-logs"
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_log_role" {
  name = "VPCFlowLogsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
      Effect    = "Allow"
      Sid       = ""
    }]
  })
}

# Attach policy to allow logging
resource "aws_iam_role_policy_attachment" "vpc_flow_log_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSVPCFlowLogs"
  role       = aws_iam_role.vpc_flow_log_role.name
}

# Create Lambda function for automated response
resource "aws_lambda_function" "guardduty_response" {
  function_name = "GuardDutyAutomatedResponse"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  filename      = "lambda_function.zip"  # Ensure this zip file is prepared with your code

  source_code_hash = filebase64sha256("lambda_function.zip")

  environment = {
    SNS_TOPIC_ARN = aws_sns_topic.guardduty_alerts.arn
  }
}

# IAM Role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "LambdaGuardDutyRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect    = "Allow"
      Sid       = ""
    }]
  })
}

# Attach policy to allow Lambda to publish to SNS
resource "aws_iam_role_policy_attachment" "lambda_sns_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_publish_sns" {
  policy_arn = "arn:aws:iam::aws:policy/AWSSNSFullAccess"
  role       = aws_iam_role.lambda_role.name
}

# Outputs
output "guardduty_detector_id" {
  value = aws_guardduty_detector.main.id
}

output "sns_topic_arn" {
  value = aws_sns_topic.guardduty_alerts.arn
}