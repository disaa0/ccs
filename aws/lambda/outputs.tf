output "file_validator_invoke_arn" {
  value       = aws_lambda_function.file_validator.invoke_arn
  description = "Invoke ARN of the file_validator Lambda function"
}

output "file_validator_name" {
  value       = aws_lambda_function.file_validator.function_name
  description = "Name of the Lambda file_validator function"
}

