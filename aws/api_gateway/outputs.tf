output "api_id" {
  description = "The ID of the API Gateway API"
  value       = aws_apigatewayv2_api.ccs.id
}

output "api_url" {
  description = "The Invoke URL of the API Gateway API"
  value       = aws_apigatewayv2_stage.dev_stage.invoke_url
}

output "lambda_file_validator_integration_id" {
  description = "The ID of the API Gateway integration for the Lambda function 'file_validator'"
  value       = aws_apigatewayv2_integration.lambda_file_validator.id
}

output "dev_stage_id" {
  description = "The ID of the dev stage in API Gateway"
  value       = aws_apigatewayv2_stage.dev_stage.id
}
