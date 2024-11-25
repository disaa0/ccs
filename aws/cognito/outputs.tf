output "user_pool_id" {
  value       = aws_cognito_user_pool.ccs_user_pool.id
  description = "The ID of the Cognito User Pool"
}

output "user_pool_arn" {
  value       = aws_cognito_user_pool.ccs_user_pool.arn
  description = "The ARN of the Cognito User Pool"
}

output "user_pool_client_id" {
  value       = aws_cognito_user_pool_client.ccs_user_pool_client.id
  description = "The ID of the Cognito User Pool Client"
}

output "identity_pool_id" {
  value       = aws_cognito_identity_pool.ccs_identity_pool.id
  description = "The ID of the Cognito Identity Pool"
}
