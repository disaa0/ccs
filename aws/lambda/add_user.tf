# IAM Policy for Lambda (Allow Creating IAM Roles & Attaching Policies)
resource "aws_iam_policy" "ccs_add_user" {
  name        = "LambdaIAMProvisioningPolicy"
  description = "Allows Lambda to create IAM roles and attach policies"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:AttachRolePolicy",
        "iam:PutRolePolicy",
        "iam:GetRole",
        "sts:AssumeRole"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject"],
      "Resource": "arn:aws:s3:::tul-ccs/*"
    }
  ]
}
EOF
}

# Attach IAM Policy to Lambda Role
resource "aws_iam_role_policy_attachment" "ccs_add_user" {
  role       = aws_iam_role.ccs_lambda.name
  policy_arn = aws_iam_policy.ccs_add_user.arn
}

# Zip file for Lambda function
data "archive_file" "add_user" {
  type        = "zip"
  source_file = "${path.module}/functions/add_user/index.py"
  output_path = "${path.module}/functions/add_user.zip"
}


# Deploy Lambda Function
resource "aws_lambda_function" "add_user" {
  filename      = data.archive_file.add_user.output_path
  function_name = "UserProvisioningLambda"
  role          = aws_iam_role.ccs_lambda.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  memory_size   = 256
  source_code_hash = data.archive_file.add_user.output_base64sha256
  environment {
    variables = {
      BUCKET_NAME = var.s3_bucket_id
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.ccs_add_user,
    data.archive_file.add_user
  ]
}
