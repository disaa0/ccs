output "user_permissions_table_name" {
  value       = aws_dynamodb_table.user_permissions.name
  description = "The name of the DynamoDB user permissions table"
}

output "user_permissions_table_arn" {
  value       = aws_dynamodb_table.user_permissions.arn
  description = "The ARN of the DynamoDB user permissions table"
}
