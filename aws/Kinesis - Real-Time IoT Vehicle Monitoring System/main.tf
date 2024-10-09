provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

# Create a Kinesis Data Stream
resource "aws_kinesis_stream" "vehicle_telemetry_stream" {
  name        = "vehicle-telemetry-stream"
  shard_count = 1
}

# Create an IAM Role for Kinesis Firehose
resource "aws_iam_role" "firehose_role" {
  name = "kinesis_firehose_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# Attach policies to the Firehose role
resource "aws_iam_role_policy_attachment" "firehose_policy" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFirehoseFullAccess"
}

# Create a Kinesis Data Firehose Delivery Stream
resource "aws_kinesis_firehose_delivery_stream" "vehicle_data_firehose" {
  name        = "vehicle-data-firehose"
  destination = "s3"

  s3_configuration {
    bucket_arn = aws_s3_bucket.vehicle_data_bucket.arn
    role_arn   = aws_iam_role.firehose_role.arn
  }
}

# Create an S3 Bucket for Firehose
resource "aws_s3_bucket" "vehicle_data_bucket" {
  bucket = "vehicle-data-bucket-123456"  # Change to a unique bucket name
}

# Output the stream name and Firehose delivery stream
output "kinesis_stream_name" {
  value = aws_kinesis_stream.vehicle_telemetry_stream.name
}

output "firehose_stream_name" {
  value = aws_kinesis_firehose_delivery_stream.vehicle_data_firehose.name
}