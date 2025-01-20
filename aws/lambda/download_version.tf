# Zip file for Lambda function
data "archive_file" "download_version" {
  type        = "zip"
  source_file = "${path.module}/functions/download_version/index.py"
  output_path = "${path.module}/functions/download_version.zip"
}

resource "aws_lambda_function" "download_version" {
  filename         = data.archive_file.download_version.output_path
  function_name    = "DownloadFileVersions"
  role             = aws_iam_role.ccs_lambda.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.9"
  memory_size      = 256
  timeout          = 30
  source_code_hash = data.archive_file.download_version.output_base64sha256

  lifecycle {
    ignore_changes = [
      qualified_arn
    ]
  }
  environment {
    variables = {
      BUCKET_NAME = var.s3_bucket_id
    }
  }
  depends_on = [
    data.archive_file.download_version
  ]
}
