#!/bin/bash

# Variables
REGION="us-west-2"  # Change to your preferred region
S3_BUCKET_NAME="my-cloudtrail-logs-unique-id"  # Ensure this bucket name is globally unique
SNS_TOPIC_NAME="GuardDutyAlerts"
LAMBDA_FUNCTION_NAME="GuardDutyAutomatedResponse"
ROLE_NAME="LambdaGuardDutyRole"
CLOUDTRAIL_NAME="my-cloudtrail"

# Create S3 bucket for CloudTrail logs
aws s3api create-bucket --bucket "$S3_BUCKET_NAME" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION"

# Enable CloudTrail
aws cloudtrail create-trail --name "$CLOUDTRAIL_NAME" --s3-bucket-name "$S3_BUCKET_NAME" --include-global-service-events --is-multi-region-trail
aws cloudtrail start-logging --name "$CLOUDTRAIL_NAME"

# Enable GuardDuty
GUARDDUTY_DETECTOR_ID=$(aws guardduty create-detector --enable --output text)

# Create SNS topic for GuardDuty alerts
SNS_TOPIC_ARN=$(aws sns create-topic --name "$SNS_TOPIC_NAME" --output text)

# Subscribe email to the SNS topic (Replace with your email)
aws sns subscribe --topic-arn "$SNS_TOPIC_ARN" --protocol email --notification-endpoint "your_email@example.com"  # Change to your email

# Create IAM role for Lambda function
ROLE_ARN=$(aws iam create-role --role-name "$ROLE_NAME" --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}' --output text --query 'Role.Arn')

# Attach policy to allow Lambda to publish to SNS
aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "arn:aws:iam::aws:policy/AWSSNSFullAccess"

# Create the Lambda function (assuming you have the zip file ready)
aws lambda create-function --function-name "$LAMBDA_FUNCTION_NAME" --runtime python3.8 --role "$ROLE_ARN" --handler lambda_function.lambda_handler --zip-file fileb://lambda_function.zip --environment "SNS_TOPIC_ARN=$SNS_TOPIC_ARN"

# Create VPC Flow Logs (assuming you have a VPC ID)
VPC_ID="vpc-abc123"  # Change to your VPC ID
aws ec2 create-flow-logs --resource-type VPC --resource-id "$VPC_ID" --traffic-type ALL --log-destination-type cloud-watch-logs --log-destination "arn:aws:logs:$REGION:$(aws sts get-caller-identity --query Account --output text):log-group:vpc-flow-logs"

# Output summary
echo "GuardDuty Detector ID: $GUARDDUTY_DETECTOR_ID"
echo "SNS Topic ARN: $SNS_TOPIC_ARN"