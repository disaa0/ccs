# Cognito User Pool
resource "aws_cognito_user_pool" "ccs_user_pool" {
  name = "ccs_user_pool"
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
    client_id   = aws_cognito_user_pool_client.ccs_user_pool_client.id
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
            "cognito-identity.amazonaws.com:aud": aws_cognito_identity_pool.ccs_identity_pool.id
          },
          "ForAnyValue:StringLike": {
            "cognito-identity.amazonaws.com:amr": "authenticated"
          }
        }
      }
    ]
  })
}

# Policy that allows dynamic access based on permissions
resource "aws_iam_role_policy" "authenticated_role_policy" {
  role = aws_iam_role.authenticated_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::ccs"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = "arn:aws:s3:::ccs/*",
        Condition = {
          "StringEquals": {
            "aws:RequestTag/Permission": "$${aws:username}"  # Permissions are checked dynamically
          }
        }
      }
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
