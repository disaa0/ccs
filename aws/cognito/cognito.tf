# Cognito User Pool
resource "aws_cognito_user_pool" "ccs_user_pool" {
  name                     = "ccs_user_pool"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  # alias_attributes         = ["email"]

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = false
  }

  admin_create_user_config {
    allow_admin_create_user_only = false #
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "ccs_user_pool_client" {
  name         = "ccs_user_pool_client"
  user_pool_id = aws_cognito_user_pool.ccs_user_pool.id
}

# Cognito Identity Pool
resource "aws_cognito_identity_pool" "ccs_identity_pool" {
  identity_pool_name               = "ccs_identity_pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id     = aws_cognito_user_pool_client.ccs_user_pool_client.id
    provider_name = aws_cognito_user_pool.ccs_user_pool.endpoint
  }
}

# IAM Role for authenticated users
resource "aws_iam_role" "authenticated_role" {
  name = "ccs_authenticated_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" : aws_cognito_identity_pool.ccs_identity_pool.id
          },
          "ForAnyValue:StringLike" : {
            "cognito-identity.amazonaws.com:amr" : "authenticated"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "authenticated_role_policy" {
  role = aws_iam_role.authenticated_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "s3:ListBucket",
        "Effect" : "Allow",
        "Resource" : "arn:aws:s3:::tul-ccs"
      },
      # {
      # 	"Action": "s3:GetObject",
      # 	"Effect": "Allow",
      # 	"Resource": "arn:aws:s3:::tul-ccs/*"
      # },
      # {
      # 	"Action": "s3:PutObject",
      # 	"Effect": "Allow",
      # 	"Resource": "arn:aws:s3:::tul-ccs/*"
      # },
      # {
      # 	"Action": "s3:DeleteObject",
      # 	"Effect": "Allow",
      # 	"Resource": "arn:aws:s3:::tul-ccs/*"
      # }
    ]
  })
}

# Cognito Identity Pool Roles Attachment
resource "aws_cognito_identity_pool_roles_attachment" "identity_pool_roles" {
  identity_pool_id = aws_cognito_identity_pool.ccs_identity_pool.id

  roles = {
    authenticated = aws_iam_role.authenticated_role.arn
  }
}

