# Zip file for Lambda function
data "archive_file" "file_validator" {
  type        = "zip"
  source_file = "${path.module}/functions/file_validator/index.py"
  output_path = "${path.module}/functions/file_validator.zip"
}

resource "aws_lambda_function" "file_validator" {
  filename         = data.archive_file.file_validator.output_path
  function_name    = "FileValidatorLambda"
  role            = aws_iam_role.ccs_lambda.arn
  handler         = "index.lambda_handler"
  runtime         = "python3.9"
  timeout         = 30
  memory_size     = 256
  source_code_hash = data.archive_file.file_validator.output_base64sha256

  environment {
    variables = {

    }
  }

  depends_on = [
    # aws_iam_role_policy_attachment.file_validator,
    data.archive_file.file_validator
  ]
}
