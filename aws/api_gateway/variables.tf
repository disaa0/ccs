variable "lambda_file_validator_name" {
  type        = string
  description = "The name of the file validation Lambda function"
}

variable "lambda_file_validator_invoke_arn" {
  type        = string
  description = "The Invoke ARN of the file validation Lambda function"
}

variable "lambda_file_versions_name" {
  type        = string
  description = "The name of the file versions Lambda function"
}

variable "lambda_file_versions_invoke_arn" {
  type        = string
  description = "The Invoke ARN of the file versions Lambda function"
}

variable "lambda_download_version_name" {
  type        = string
  description = "The name of the download version Lambda function"
}

variable "lambda_download_version_invoke_arn" {
  type        = string
  description = "The Invoke ARN of the download version Lambda function"
}

variable "lambda_restore_version_name" {
  type        = string
  description = "The name of the restore versionLambda function"
}

variable "lambda_restore_version_invoke_arn" {
  type        = string
  description = "The Invoke ARN of the restore version Lambda function"
}

variable "lambda_log_event_name" {
  type        = string
  description = "The name of the log event Lambda function"
}

variable "lambda_log_event_invoke_arn" {
  type        = string
  description = "The Invoke ARN of the log event Lambda function"
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
