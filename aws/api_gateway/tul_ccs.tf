resource "aws_apigatewayv2_api" "ccs" {
  name          = "tul_ccs_api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins  = ["*"] # Replace with your specific origins in production
    allow_methods  = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers  = ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token"]
    expose_headers = ["*"]
    max_age        = 300
  }
}

resource "aws_lambda_permission" "apigateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_file_validator_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.ccs.execution_arn}/*"
}

resource "aws_apigatewayv2_integration" "lambda_file_validator" {
  api_id           = aws_apigatewayv2_api.ccs.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_file_validator_invoke_arn
}

# Add CORS headers to all responses via response parameters
resource "aws_apigatewayv2_route" "validate_zip" {
  api_id    = aws_apigatewayv2_api.ccs.id
  route_key = "POST /validate-zip"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_file_validator.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_auth.id
}

# Deploy API Gateway Stage
resource "aws_apigatewayv2_stage" "dev_stage" {
  api_id      = aws_apigatewayv2_api.ccs.id
  name        = "dev"
  auto_deploy = true
}

resource "aws_apigatewayv2_authorizer" "cognito_auth" {
  api_id           = aws_apigatewayv2_api.ccs.id
  name             = "CognitoAuthorizer"
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [var.cognito_user_pool_client_id]
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${var.cognito_user_pool_id}"
  }
}
