provider "aws" {
  region = "us-west-2" # Change to your desired region
}

# Create IAM Policy for Development Group
resource "aws_iam_policy" "dev_policy" {
  name        = "DevPolicy"
  description = "Policy for Development group to manage development resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "s3:*",
          "rds:*"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Environment" = "Development"
          }
        }
      },
      {
        Effect = "Deny"
        Action = "*"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Environment" = "Production"
          }
        }
      }
    ]
  })
}

# Create IAM Group for Development
resource "aws_iam_group" "dev_group" {
  name = "DevelopmentGroup"
}

# Attach Development Policy to Development Group
resource "aws_iam_policy_attachment" "dev_policy_attachment" {
  name       = "DevPolicyAttachment"
  policy_arn = aws_iam_policy.dev_policy.arn
  groups     = [aws_iam_group.dev_group.name]
}

# Create IAM Policy for QA Group
resource "aws_iam_policy" "qa_policy" {
  name        = "QAPolicy"
  description = "Policy for QA group to access resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

# Create IAM Group for QA
resource "aws_iam_group" "qa_group" {
  name = "QAGroup"
}

# Attach QA Policy to QA Group
resource "aws_iam_policy_attachment" "qa_policy_attachment" {
  name       = "QAPolicyAttachment"
  policy_arn = aws_iam_policy.qa_policy.arn
  groups     = [aws_iam_group.qa_group.name]
}

# Create IAM Users (example)
resource "aws_iam_user" "dev_user" {
  count = 3 # Change the number to add more users
  name  = "dev_user_${count.index + 1}"
}

resource "aws_iam_user_group_membership" "dev_user_membership" {
  count  = 3 # Change the number to match the users created
  user   = aws_iam_user.dev_user[count.index].name
  groups = [aws_iam_group.dev_group.name]
}

resource "aws_iam_user" "qa_user" {
  count = 2 # Change the number to add more users
  name  = "qa_user_${count.index + 1}"
}

resource "aws_iam_user_group_membership" "qa_user_membership" {
  count  = 2 # Change the number to match the users created
  user   = aws_iam_user.qa_user[count.index].name
  groups = [aws_iam_group.qa_group.name]
}