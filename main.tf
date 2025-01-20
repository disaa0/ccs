terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.54.1"
    }
  }
  backend "s3" {
    bucket = "tul-ccs-terraform"
    key    = "terraform.tfstate"
    region = "eu-north-1"
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
  source     = "./aws/cognito"
  aws_region = "eu-north-1"
}

# DynamoDB Module
module "dynamodb" {
  source = "./aws/dynamodb"
}

# Lambda Module
module "lambda" {
  source = "./aws/lambda"

  cognito_user_pool_arn       = module.cognito.user_pool_arn
  cognito_user_pool_id        = module.cognito.user_pool_id
  cognito_user_pool_client_id = module.cognito.user_pool_client_id
  dynamodb_table_name         = module.dynamodb.user_logbook_table_name
  dynamodb_table_arn          = module.dynamodb.user_logbook_table_arn
  s3_bucket_id                = module.s3.bucket_id
  s3_bucket_arn               = module.s3.bucket_arn

  depends_on = [
    module.cognito,
    module.dynamodb,
    module.s3
  ]
}

# API Gateway Module
module "api_gateway" {
  source = "./aws/api_gateway"

  lambda_file_validator_name         = module.lambda.file_validator_name
  lambda_file_validator_invoke_arn   = module.lambda.file_validator_invoke_arn
  lambda_download_version_name       = module.lambda.download_version_name
  lambda_download_version_invoke_arn = module.lambda.download_version_invoke_arn
  lambda_restore_version_name        = module.lambda.restore_version_name
  lambda_restore_version_invoke_arn  = module.lambda.restore_version_invoke_arn
  lambda_file_versions_name          = module.lambda.file_versions_name
  lambda_file_versions_invoke_arn    = module.lambda.file_versions_invoke_arn
  lambda_log_event_name              = module.lambda.log_event_name
  lambda_log_event_invoke_arn        = module.lambda.log_event_invoke_arn
  cognito_user_pool_client_id        = module.cognito.user_pool_client_id
  cognito_user_pool_id               = module.cognito.user_pool_id
  aws_region                         = "eu-north-1"

  depends_on = [
    module.lambda,
    module.cognito
  ]
}
