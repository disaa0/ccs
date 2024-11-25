output "auth_lambda_function_name" {
  value       = aws_lambda_function.auth_handler.function_name
  description = "The name of the authentication Lambda function"
}

output "auth_lambda_function_arn" {
  value       = aws_lambda_function.auth_handler.arn
  description = "The ARN of the authentication Lambda function"
}

output "auth_lambda_function_invoke_arn" {
  value       = aws_lambda_function.auth_handler.invoke_arn
  description = "The invoke ARN of the authentication Lambda function - useful for API Gateway integration"
}

output "auth_lambda_role_arn" {
  value       = aws_iam_role.auth_lambda_role.arn
  description = "The ARN of the IAM role used by the Lambda function"
}

output "auth_lambda_role_name" {
  value       = aws_iam_role.auth_lambda_role.name
  description = "The name of the IAM role used by the Lambda function"
}

output "auth_lambda_log_group_name" {
  value       = aws_cloudwatch_log_group.auth_lambda_logs.name
  description = "The name of the CloudWatch Log Group for the Lambda function"
}

output "auth_lambda_log_group_arn" {
  value       = aws_cloudwatch_log_group.auth_lambda_logs.arn
  description = "The ARN of the CloudWatch Log Group for the Lambda function"
}

output "auth_lambda_qualified_arn" {
  value       = aws_lambda_function.auth_handler.qualified_arn
  description = "The qualified ARN of the Lambda function including the version"
}

output "auth_lambda_version" {
  value       = aws_lambda_function.auth_handler.version
  description = "The version of the Lambda function"
}

output "auth_lambda_source_code_hash" {
  value       = aws_lambda_function.auth_handler.source_code_hash
  description = "Base64-encoded SHA256 hash of the Lambda function source code"
}

output "auth_lambda_last_modified" {
  value       = aws_lambda_function.auth_handler.last_modified
  description = "The date the Lambda function was last modified"
}
