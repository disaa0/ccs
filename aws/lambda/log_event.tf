# Zip file for Lambda function
data "archive_file" "log_event" {
  type        = "zip"
  source_file = "${path.module}/functions/log_event/index.py"
  output_path = "${path.module}/functions/log_event.zip"
}

resource "aws_lambda_function" "log_event" {
  filename         = data.archive_file.log_event.output_path
  function_name    = "LogEvent"
  role             = aws_iam_role.ccs_lambda.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.9"
  memory_size      = 256
  timeout          = 30
  source_code_hash = data.archive_file.log_event.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
    }
  }

  lifecycle {
    ignore_changes = [
      qualified_arn
    ]
  }

  depends_on = [
    data.archive_file.log_event
  ]
}
