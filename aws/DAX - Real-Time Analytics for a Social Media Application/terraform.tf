provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

# Create the Users Table
resource "aws_dynamodb_table" "users" {
  name         = "Users"
  billing_mode = "PAY_PER_REQUEST"  # On-demand mode

  attribute {
    name = "UserID"
    type = "S"
  }

  hash_key = "UserID"

  tags = {
    Name = "UsersTable"
  }
}

# Create the Posts Table
resource "aws_dynamodb_table" "posts" {
  name         = "Posts"
  billing_mode = "PAY_PER_REQUEST"  # On-demand mode

  attribute {
    name = "PostID"
    type = "S"
  }

  attribute {
    name = "UserID"
    type = "S"
  }

  hash_key = "PostID"

  tags = {
    Name = "PostsTable"
  }
}

# Create the DAX Cluster
resource "aws_dax_cluster" "dax_cluster" {
  cluster_name = "SnapConnectDAX"
  node_type    = "dax.r4.large"  # Choose an appropriate instance type
  replication_factor = 1           # Number of nodes; increase for high availability

  tags = {
    Name = "SnapConnectDAXCluster"
  }

  # Associate the DAX cluster with the DynamoDB tables
  iam_role_arn = aws_iam_role.dax_role.arn
}

# IAM Role for DAX
resource "aws_iam_role" "dax_role" {
  name = "DAXRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = {
        Service = "dax.amazonaws.com"
      }
      Effect    = "Allow"
      Sid       = ""
    }]
  })
}

# Attach policy to the DAX role
resource "aws_iam_role_policy_attachment" "dax_policy_attachment" {
  role       = aws_iam_role.dax_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole"
}

# Outputs for verification
output "users_table_name" {
  value = aws_dynamodb_table.users.name
}

output "posts_table_name" {
  value = aws_dynamodb_table.posts.name
}

output "dax_cluster_endpoint" {
  value = aws_dax_cluster.dax_cluster.endpoint
}