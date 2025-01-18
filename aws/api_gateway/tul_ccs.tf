resource "aws_apigatewayv2_api" "ccs" {
  name          = "tul_ccs_api"
  protocol_type = "HTTP"
}

# API Gateway Integration with Lambda
resource "aws_apigatewayv2_integration" "lambda_add_user" {
  api_id           = aws_apigatewayv2_api.ccs.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_add_user_invoke_arn
}
resource "aws_apigatewayv2_integration" "lambda_file_validator" {
  api_id           = aws_apigatewayv2_api.ccs.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_file_validator_invoke_arn
}

# Deploy API Gateway Stage
resource "aws_apigatewayv2_stage" "dev_stage" {
  api_id      = aws_apigatewayv2_api.ccs.id
  name        = "dev"
  auto_deploy = true
}

resource "aws_apigatewayv2_route" "post_user" {
  api_id             = aws_apigatewayv2_api.ccs.id
  route_key          = "POST /user"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_add_user.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_auth.id
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
