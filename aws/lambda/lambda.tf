resource "aws_lambda_function" "permission_checker" {
  filename      = "lambda_function.zip"  # Zip file containing lambda code
  function_name = "CheckUserPermissions"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.user_permissions.name
    }
  }
}

data "archive_file" "permission_checker" {
  type        = "zip"
  source_file = "./src/lambda/functions/permission_checker.py"
  output_path = "./aws/lambda/functions/permission_checker.zip"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Policy to allow Lambda to read from DynamoDB and update S3 policy
resource "aws_iam_role_policy" "lambda_execution_policy" {
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["dynamodb:GetItem", "dynamodb:Query"],
        Resource = "${aws_dynamodb_table.user_permissions.arn}"
      },
      {
        Effect = "Allow",
        Action = ["s3:PutBucketPolicy"],
        Resource = "arn:aws:s3:::ccs"
      }
    ]
  })
}

