resource "aws_api_gateway_rest_api" "auth_api" {
  name = "ccs-auth-api"
  description = "API for authentication and authorization"
}

# API Resources
resource "aws_api_gateway_resource" "auth" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  parent_id   = aws_api_gateway_rest_api.auth_api.root_resource_id
  path_part   = "auth"
}

# Login endpoint
resource "aws_api_gateway_resource" "login" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "login"
}

# Register endpoint
resource "aws_api_gateway_resource" "register" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "register"
}

# HTTP Methods
resource "aws_api_gateway_method" "login_post" {
  rest_api_id   = aws_api_gateway_rest_api.auth_api.id
  resource_id   = aws_api_gateway_resource.login.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "register_post" {
  rest_api_id   = aws_api_gateway_rest_api.auth_api.id
  resource_id   = aws_api_gateway_resource.register.id
  http_method   = "POST"
  authorization = "NONE"
}

# Lambda Integration
resource "aws_api_gateway_integration" "login_lambda" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.login.id
  http_method = aws_api_gateway_method.login_post.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = var.auth_lambda_function_invoke_arn
}

resource "aws_api_gateway_integration" "register_lambda" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.register.id
  http_method = aws_api_gateway_method.register_post.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = var.auth_lambda_function_invoke_arn
}

# CORS Configuration
resource "aws_api_gateway_method" "login_options" {
  rest_api_id   = aws_api_gateway_rest_api.auth_api.id
  resource_id   = aws_api_gateway_resource.login.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "register_options" {
  rest_api_id   = aws_api_gateway_rest_api.auth_api.id
  resource_id   = aws_api_gateway_resource.register.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# CORS Integration
resource "aws_api_gateway_integration" "login_options" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.login.id
  http_method = aws_api_gateway_method.login_options.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "register_options" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.register.id
  http_method = aws_api_gateway_method.register_options.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# CORS Method Response
resource "aws_api_gateway_method_response" "login_options_200" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.login.id
  http_method = aws_api_gateway_method.login_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "register_options_200" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.register.id
  http_method = aws_api_gateway_method.register_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# CORS Integration Response
resource "aws_api_gateway_integration_response" "login_options" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.login.id
  http_method = aws_api_gateway_method.login_options.http_method
  status_code = aws_api_gateway_method_response.login_options_200.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_integration_response" "register_options" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.register.id
  http_method = aws_api_gateway_method.register_options.http_method
  status_code = aws_api_gateway_method_response.register_options_200.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Deployment
resource "aws_api_gateway_deployment" "auth_api" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  
  depends_on = [
    aws_api_gateway_integration.login_lambda,
    aws_api_gateway_integration.register_lambda,
    aws_api_gateway_integration.login_options,
    aws_api_gateway_integration.register_options,
    aws_api_gateway_integration_response.login_options,
    aws_api_gateway_integration_response.register_options
  ]
}

# Stage
resource "aws_api_gateway_stage" "auth_api" {
  deployment_id = aws_api_gateway_deployment.auth_api.id
  rest_api_id  = aws_api_gateway_rest_api.auth_api.id
  stage_name   = "prod"
}

# Lambda permissions
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.auth_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.auth_api.execution_arn}/*/*"
}
