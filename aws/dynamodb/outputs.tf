output "user_logbook_table_name" {
  value       = aws_dynamodb_table.user_logbook.name
  description = "The name of the DynamoDB user logbook table"
}

output "user_logbook_table_arn" {
  value       = aws_dynamodb_table.user_logbook.arn
  description = "The ARN of the DynamoDB user logbook table"
}
