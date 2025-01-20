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

resource "aws_lambda_permission" "apigateway_file_validator" {
  statement_id  = "AllowAPIGatewayInvokeFileValidator"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_file_validator_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.ccs.execution_arn}/*"
}

resource "aws_lambda_permission" "apigateway_file_versions" {
  statement_id  = "AllowAPIGatewayInvokeFileVersions"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_file_versions_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ccs.execution_arn}/*"
}

resource "aws_lambda_permission" "apigateway_download_version" {
  statement_id  = "AllowAPIGatewayInvokeDownloadVersion"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_download_version_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ccs.execution_arn}/*"
}

resource "aws_lambda_permission" "apigateway_restore_version" {
  statement_id  = "AllowAPIGatewayInvokeRestoreVersion"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_restore_version_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ccs.execution_arn}/*"
}

resource "aws_lambda_permission" "apigateway_log_event" {
  statement_id  = "AllowAPIGatewayInvokeLogEvent"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_log_event_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ccs.execution_arn}/*"
}

resource "aws_apigatewayv2_integration" "lambda_file_validator" {
  api_id           = aws_apigatewayv2_api.ccs.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_file_validator_invoke_arn
}

resource "aws_apigatewayv2_route" "validate_zip" {
  api_id    = aws_apigatewayv2_api.ccs.id
  route_key = "POST /validate-zip"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_file_validator.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_auth.id
}

resource "aws_apigatewayv2_integration" "lambda_file_versions" {
  api_id           = aws_apigatewayv2_api.ccs.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_file_versions_invoke_arn
}

resource "aws_apigatewayv2_route" "file_versions" {
  api_id    = aws_apigatewayv2_api.ccs.id
  route_key = "GET /file-versions"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_file_versions.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_auth.id
}

resource "aws_apigatewayv2_integration" "lambda_download_version" {
  api_id           = aws_apigatewayv2_api.ccs.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_download_version_invoke_arn
}

resource "aws_apigatewayv2_route" "download_version" {
  api_id    = aws_apigatewayv2_api.ccs.id
  route_key = "GET /download-version"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_download_version.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_auth.id
}

resource "aws_apigatewayv2_integration" "lambda_restore_version" {
  api_id           = aws_apigatewayv2_api.ccs.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_restore_version_invoke_arn
}

resource "aws_apigatewayv2_route" "restore_version" {
  api_id    = aws_apigatewayv2_api.ccs.id
  route_key = "POST /restore-version"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_restore_version.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_auth.id
}

resource "aws_apigatewayv2_integration" "lambda_log_event" {
  api_id           = aws_apigatewayv2_api.ccs.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_log_event_invoke_arn
}

resource "aws_apigatewayv2_route" "log_event" {
  api_id    = aws_apigatewayv2_api.ccs.id
  route_key = "POST /log-event"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_log_event.id}"

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
