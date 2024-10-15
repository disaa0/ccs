# DynamoDB Table to store user permissions
resource "aws_dynamodb_table" "user_permissions" {
  name         = "ccs_user_permissions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "permission"
    type = "S"
  }

  global_secondary_index {
    name            = "permission_index"
    hash_key        = "permission"
    projection_type = "ALL"
  }
}

