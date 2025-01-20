output "file_validator_invoke_arn" {
  value       = aws_lambda_function.file_validator.invoke_arn
  description = "Invoke ARN of the file_validator Lambda function"
}

output "file_validator_name" {
  value       = aws_lambda_function.file_validator.function_name
  description = "Name of the Lambda file_validator function"
}

output "download_version_invoke_arn" {
  value       = aws_lambda_function.download_version.invoke_arn
  description = "Invoke ARN of the download_version Lambda function"
}

output "download_version_name" {
  value       = aws_lambda_function.download_version.function_name
  description = "Name of the Lambda download_version function"
}


output "file_versions_invoke_arn" {
  value       = aws_lambda_function.file_versions.invoke_arn
  description = "Invoke ARN of the file_versions Lambda function"
}

output "file_versions_name" {
  value       = aws_lambda_function.file_versions.function_name
  description = "Name of the Lambda file_versions function"
}


output "restore_version_invoke_arn" {
  value       = aws_lambda_function.restore_version.invoke_arn
  description = "Invoke ARN of the restore_version Lambda function"
}

output "restore_version_name" {
  value       = aws_lambda_function.restore_version.function_name
  description = "Name of the Lambda restore_version function"
}


output "log_event_invoke_arn" {
  value       = aws_lambda_function.log_event.invoke_arn
  description = "Invoke ARN of the log_event Lambda function"
}

output "log_event_name" {
  value       = aws_lambda_function.log_event.function_name
  description = "Name of the Lambda log_event function"
}

