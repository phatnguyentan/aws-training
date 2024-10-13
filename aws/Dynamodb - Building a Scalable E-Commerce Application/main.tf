provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

# Create the Products Table
resource "aws_dynamodb_table" "products" {
  name           = "Products"
  billing_mode   = "PAY_PER_REQUEST"  # On-demand mode
  hash_key       = "ProductID"

  attribute {
    name = "ProductID"
    type = "S"
  }

  attribute {
    name = "Name"
    type = "S"
  }

  attribute {
    name = "Price"
    type = "N"
  }

  attribute {
    name = "Description"
    type = "S"
  }

  attribute {
    name = "InventoryCount"
    type = "N"
  }

  tags = {
    Name = "ProductsTable"
  }
}

# Create the Carts Table
resource "aws_dynamodb_table" "carts" {
  name           = "Carts"
  billing_mode   = "PAY_PER_REQUEST"  # On-demand mode
  hash_key       = "UserID"
  range_key      = "ProductID"

  attribute {
    name = "UserID"
    type = "S"
  }

  attribute {
    name = "ProductID"
    type = "S"
  }

  attribute {
    name = "Quantity"
    type = "N"
  }

  tags = {
    Name = "CartsTable"
  }
}

# Create the Orders Table
resource "aws_dynamodb_table" "orders" {
  name           = "Orders"
  billing_mode   = "PAY_PER_REQUEST"  # On-demand mode
  hash_key       = "OrderID"

  attribute {
    name = "OrderID"
    type = "S"
  }

  attribute {
    name = "UserID"
    type = "S"
  }

  attribute {
    name = "ProductList"
    type = "S"  # This could be a JSON string or a list depending on how you want to structure it
  }

  attribute {
    name = "TotalPrice"
    type = "N"
  }

  attribute {
    name = "OrderDate"
    type = "S"  # Consider using ISO 8601 format for dates
  }

  tags = {
    Name = "OrdersTable"
  }
}

# Outputs for verification
output "products_table_name" {
  value = aws_dynamodb_table.products.name
}

output "carts_table_name" {
  value = aws_dynamodb_table.carts.name
}

output "orders_table_name" {
  value = aws_dynamodb_table.orders.name
}