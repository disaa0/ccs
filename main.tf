terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.54.1"
    }
  }
  backend "s3" {
    bucket         = "tul-ccs-terraform"
    key            = "terraform.tfstate"
    region         = "eu-north-1"
    # dynamodb_table = "terraform-lock" # Optional: Add a DynamoDB table for state locking
  }
}

provider "aws" {
  region = "eu-north-1"
}

# S3 Module
module "s3" {
  source = "./aws/s3"
}

# Cognito Module
module "cognito" {
  source = "./aws/cognito"
}

# DynamoDB Module
module "dynamodb" {
  source = "./aws/dynamodb"
}

# Lambda Module
module "lambda" {
  source = "./aws/lambda"
  # Vars
  cognito_user_pool_arn       = module.cognito.user_pool_arn
  cognito_user_pool_id        = module.cognito.user_pool_id
  cognito_user_pool_client_id = module.cognito.user_pool_client_id
  dynamodb_table_name         = module.dynamodb.user_permissions_table_name
  dynamodb_table_arn          = module.dynamodb.user_permissions_table_arn

  depends_on = [
    module.cognito,
    module.dynamodb
  ]
}

# API Gateway Module
module "api_gateway" {
  source = "./aws/api_gateway"

   auth_lambda_function_name  = module.lambda.auth_lambda_function_name
   auth_lambda_function_invoke_arn  = module.lambda.auth_lambda_function_invoke_arn

  depends_on = [
    module.lambda
  ]
}
