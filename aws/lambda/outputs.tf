output "add_user_invoke_arn" {
  value       = aws_lambda_function.add_user.invoke_arn
  description = "Invoke ARN of the add_user Lambda function"
}

output "add_user_name" {
  value       = aws_lambda_function.add_user.function_name
  description = "Name of the Lambda add_user function"
}

output "file_validator_invoke_arn" {
  value       = aws_lambda_function.file_validator.invoke_arn
  description = "Invoke ARN of the file_validator Lambda function"
}

output "file_validator_name" {
  value       = aws_lambda_function.file_validator.function_name
  description = "Name of the Lambda file_validator function"
}

