variable "lambda_add_user_name" {
  type        = string
  description = "The name of the adduser Lambda function"
}

variable "lambda_add_user_invoke_arn" {
  type        = string
  description = "The Invoke ARN of the add user Lambda function"
}


variable "lambda_file_validator_name" {
  type        = string
  description = "The name of the file validation Lambda function"
}

variable "lambda_file_validator_invoke_arn" {
  type        = string
  description = "The Invoke ARN of the file validation Lambda function"
}

variable "cognito_user_pool_client_id" {
  type        = string
  description = "The ID of the Cognito User Pool Client"
}

variable "cognito_user_pool_id" {
  type        = string
  description = "The ID of the Cognito User Pool"
}

variable "aws_region" {
  type        = string
  description = "The AWS region"
}
