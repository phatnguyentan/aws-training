provider "aws" {
  region = "us-east-1"
}

##############
# IAM account
##############
module "iam_account" {
  source = "../modules/iam_account"

  account_alias = "new-test-account-awesome-company"

  minimum_password_length = 6
  require_numbers         = false
}