# Cognito User Pool
resource "aws_cognito_user_pool" "ccs_user_pool" {
  name                     = "ccs_user_pool"
  username_attributes      = ["email"]
  auto_verified_attributes = [""]
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
    allow_admin_create_user_only = false
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

# Base authenticated role - with minimal permissions
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

# User-specific role trust policy
resource "aws_iam_role" "user_role" {
  name = "ccs_user_role"
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

# Role mapping in the identity pool
resource "aws_cognito_identity_pool_roles_attachment" "roles_attachment" {
  identity_pool_id = aws_cognito_identity_pool.ccs_identity_pool.id

  # Default role - used if no mapping rules match
  roles = {
    authenticated = aws_iam_role.authenticated_role.arn
  }

  # # Role mapping rules
  # role_mapping {
  #   identity_provider = "${aws_cognito_user_pool.ccs_user_pool.endpoint}${aws_cognito_user_pool_client.ccs_user_pool_client.id}"
  #   type = "Rules"
  #   ambiguous_role_resolution = "Deny"
  #   
  #   mapping_rule {
  #     claim      = "cognito:username"  # Use the username claim
  #     match_type = "Contains"          # Will match if username exists
  #     role_arn   = aws_iam_role.user_role.arn
  #     value      = "*"                 # Match any username
  #   }
  # }
}

# User role permissions
resource "aws_iam_role_policy" "user_role_policy" {
  role = aws_iam_role.authenticated_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::tul-ccs",
        Condition = {
          StringLike = {
            "s3:prefix" : [
              "public/$${cognito-identity.amazonaws.com:sub}/",
              "public/$${cognito-identity.amazonaws.com:sub}/*",
            ]
          }
        }
      },
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Effect   = "Allow",
        Resource = [
          "arn:aws:s3:::tul-ccs/public/$${cognito-identity.amazonaws.com:sub}/*",
        ]
      }
    ]
  })
}
