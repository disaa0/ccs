# IAM role for Lambda
resource "aws_iam_role" "ccs_lambda" {
  name = "CCSLambdaRole"
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


# Basic Lambda execution policy attachment
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.ccs_lambda.name
}
# Basic Lambda execution policy attachment
resource "aws_iam_role_policy_attachment" "lambda_policy_test" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.ccs_lambda.name
}

resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "CCSLambdaS3Policy"
  role = aws_iam_role.ccs_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${var.s3_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          "${var.dynamodb_table_arn}/*",
          "${var.dynamodb_table_arn}"

        ]
      }
    ]
  })
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/ccs"
  retention_in_days = 14
}
