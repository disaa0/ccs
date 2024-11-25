# Lambda function for authentication
resource "aws_lambda_function" "auth_handler" {
  filename         = data.archive_file.auth_lambda.output_path
  function_name    = "ccs-auth-handler"
  role            = aws_iam_role.auth_lambda_role.arn
  handler         = "index.lambda_handler"
  runtime         = "python3.9"
  timeout         = 30
  memory_size     = 256

  environment {
    variables = {
      COGNITO_CLIENT_ID    = var.cognito_user_pool_client_id
      COGNITO_USER_POOL_ID = var.cognito_user_pool_id
      DYNAMODB_TABLE       = var.dynamodb_table_name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.auth_lambda_policy,
    data.archive_file.auth_lambda
  ]
}

# Create zip file for Lambda function
data "archive_file" "auth_lambda" {
  type        = "zip"
  source_file = "${path.module}/functions/auth_handler/index.py"
  output_path = "${path.module}/functions/auth_handler.zip"
}

# IAM role for Lambda
resource "aws_iam_role" "auth_lambda_role" {
  name = "ccs-auth-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for the Lambda role
resource "aws_iam_role_policy" "auth_lambda_policy" {
  name = "ccs-auth-lambda-policy"
  role = aws_iam_role.auth_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      },
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:AdminInitiateAuth",
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminSetUserPassword",
          "cognito-idp:SignUp",
          "cognito-idp:InitiateAuth"
        ]
        Resource = [var.cognito_user_pool_arn]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query"
        ]
        Resource = [var.dynamodb_table_arn]
      }
    ]
  })
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "auth_lambda_logs" {
  name              = "/aws/lambda/ccs-auth-handler"
  retention_in_days = 14
}

# Lambda policy attachment for basic execution
resource "aws_iam_role_policy_attachment" "auth_lambda_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.auth_lambda_role.name
}

# Additional variables for Lambda environment
variable "lambda_environment" {
  type = map(string)
  default = {
    STAGE = "prod"
  }
  description = "Environment variables for Lambda function"
}

# Output values
output "lambda_function_arn" {
  value       = aws_lambda_function.auth_handler.arn
  description = "ARN of the Lambda function"
}

output "lambda_function_name" {
  value       = aws_lambda_function.auth_handler.function_name
  description = "Name of the Lambda function"
}
