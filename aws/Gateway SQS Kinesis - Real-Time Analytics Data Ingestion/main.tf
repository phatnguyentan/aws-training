provider "aws" {
  region = "us-west-2" # Change to your desired region
}

# Step 1: Create the Kinesis Data Stream
resource "aws_kinesis_stream" "data_stream" {
  name        = "RealTimeDataStream"
  shard_count = 1 # Adjust based on your throughput needs
}

# Step 2: Create the SQS Queue
resource "aws_sqs_queue" "data_queue" {
  name = "DataIngestionQueue"
}

# Step 3: Create the API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = "DataIngestionAPI"
  description = "API for ingesting data for real-time analytics"
}

resource "aws_api_gateway_resource" "data_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "data"
}

resource "aws_api_gateway_method" "post_data" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.data_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Step 4: Integrate API Gateway with SQS
resource "aws_api_gateway_integration" "sqs_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.data_resource.id
  http_method = aws_api_gateway_method.post_data.http_method

  type             = "AWS_PROXY"
  uri              = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_sqs_queue.data_queue.name}"
  integration_http_method = "POST"
}

# Step 5: Create IAM Role for API Gateway to Send Messages to SQS
resource "aws_iam_role" "api_gateway_sqs_role" {
  name = "ApiGatewaySqsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

resource "aws_iam_policy" "sqs_policy" {
  name        = "ApiGatewaySQSPolicy"
  description = "Policy to allow API Gateway to send messages to SQS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "SQS:SendMessage"
        Resource = aws_sqs_queue.data_queue.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  policy_arn = aws_iam_policy.sqs_policy.arn
  role       = aws_iam_role.api_gateway_sqs_role.name
}

# Step 6: Enable CORS for the API Gateway (optional)
resource "aws_api_gateway_method_response" "method_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.data_resource.id
  http_method = aws_api_gateway_method.post_data.http_method
  status_code = "200"
}

resource "aws_api_gateway_options" "api_options" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.data_resource.id

  method_response {
    status_code = "200"

    response_parameters = {
      "method.response.header.Access-Control-Allow-Origin" = true
      "method.response.header.Access-Control-Allow-Methods" = true
    }
  }

  # Set CORS headers
  response_headers {
    "Access-Control-Allow-Origin" = "'*'"
    "Access-Control-Allow-Methods" = "'OPTIONS,POST'"
  }
}

# Step 7: Deploy the API
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}

# Outputs
output "api_endpoint" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}/data"
}

output "sqs_queue_url" {
  value = aws_sqs_queue.data_queue.id
}

output "kinesis_stream_name" {
  value = aws_kinesis_stream.data_stream.name
}