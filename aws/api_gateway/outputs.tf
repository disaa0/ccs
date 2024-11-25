output "api_id" {
  value       = aws_api_gateway_rest_api.auth_api.id
  description = "The ID of the API Gateway REST API"
}

output "api_arn" {
  value       = aws_api_gateway_rest_api.auth_api.arn
  description = "The ARN of the API Gateway REST API"
}

output "api_execution_arn" {
  value       = aws_api_gateway_rest_api.auth_api.execution_arn
  description = "The execution ARN of the API Gateway REST API"
}

output "api_endpoint" {
  value       = "${aws_api_gateway_stage.auth_api.invoke_url}"
  description = "The URL to invoke the API endpoint"
}

output "stage_name" {
  value       = aws_api_gateway_stage.auth_api.stage_name
  description = "The name of the API Gateway stage"
}

output "auth_resource_id" {
  value       = aws_api_gateway_resource.auth.id
  description = "The ID of the /auth resource"
}

output "login_resource_id" {
  value       = aws_api_gateway_resource.login.id
  description = "The ID of the /auth/login resource"
}

output "register_resource_id" {
  value       = aws_api_gateway_resource.register.id
  description = "The ID of the /auth/register resource"
}

# Optional but useful outputs for other integrations
output "login_url" {
  value       = "${aws_api_gateway_stage.auth_api.invoke_url}${aws_api_gateway_resource.login.path}"
  description = "The full URL for the login endpoint"
}

output "register_url" {
  value       = "${aws_api_gateway_stage.auth_api.invoke_url}${aws_api_gateway_resource.register.path}"
  description = "The full URL for the register endpoint"
}
