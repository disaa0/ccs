variable "cognito_user_pool_arn" {
  type        = string
  description = "The ARN of the Cognito User Pool"
}

variable "cognito_user_pool_id" {
  type        = string
  description = "The ID of the Cognito User Pool"
}

variable "cognito_user_pool_client_id" {
  type        = string
  description = "The ID of the Cognito User Pool Client"
}

variable "dynamodb_table_name" {
  type        = string
  description = "The name of the DynamoDB user permissions table"
}

variable "dynamodb_table_arn" {
  type        = string
  description = "The ARN of the DynamoDB user permissions table"
}

variable "s3_bucket_id" {
  type        = string
  description = "The ID of the S3 file storage bucket"
}
