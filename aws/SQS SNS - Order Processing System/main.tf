provider "aws" {
  region = "us-west-2" # Change to your desired region
}

resource "aws_sns_topic" "order_placed" {
  name = "OrderPlaced"
}

resource "aws_sqs_queue" "inventory_queue" {
  name = "InventoryQueue"
}

resource "aws_sqs_queue" "payment_queue" {
  name = "PaymentQueue"
}

resource "aws_sqs_queue" "shipping_queue" {
  name = "ShippingQueue"
}

resource "aws_sns_topic_subscription" "inventory_subscription" {
  topic_arn = aws_sns_topic.order_placed.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.inventory_queue.arn

  # Allow SNS to send messages to the SQS queue
  raw_message_delivery = true
}

resource "aws_sns_topic_subscription" "payment_subscription" {
  topic_arn = aws_sns_topic.order_placed.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.payment_queue.arn

  # Allow SNS to send messages to the SQS queue
  raw_message_delivery = true
}

resource "aws_sns_topic_subscription" "shipping_subscription" {
  topic_arn = aws_sns_topic.order_placed.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.shipping_queue.arn

  # Allow SNS to send messages to the SQS queue
  raw_message_delivery = true
}

resource "aws_sqs_queue_policy" "inventory_queue_policy" {
  queue_url = aws_sqs_queue.inventory_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action = "SQS:SendMessage"
        Resource = aws_sqs_queue.inventory_queue.arn
        Condition = {
          "ArnEquals" = {
            "aws:SourceArn" = aws_sns_topic.order_placed.arn
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "payment_queue_policy" {
  queue_url = aws_sqs_queue.payment_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action = "SQS:SendMessage"
        Resource = aws_sqs_queue.payment_queue.arn
        Condition = {
          "ArnEquals" = {
            "aws:SourceArn" = aws_sns_topic.order_placed.arn
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "shipping_queue_policy" {
  queue_url = aws_sqs_queue.shipping_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action = "SQS:SendMessage"
        Resource = aws_sqs_queue.shipping_queue.arn
        Condition = {
          "ArnEquals" = {
            "aws:SourceArn" = aws_sns_topic.order_placed.arn
          }
        }
      }
    ]
  })
}

output "sns_topic_arn" {
  value = aws_sns_topic.order_placed.arn
}

output "inventory_queue_url" {
  value = aws_sqs_queue.inventory_queue.id
}

output "payment_queue_url" {
  value = aws_sqs_queue.payment_queue.id
}

output "shipping_queue_url" {
  value = aws_sqs_queue.shipping_queue.id
}