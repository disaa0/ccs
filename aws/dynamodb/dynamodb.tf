resource "aws_dynamodb_table" "user_logbook" {
  name         = "user_logbook"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "timestamp"
  
  attribute {
    name = "user_id"
    type = "S"
  }
  
  attribute {
    name = "timestamp"
    type = "S"
  }
  
  global_secondary_index {
    name               = "EventTypeIndex"
    hash_key          = "event_type"
    range_key         = "timestamp"
    projection_type    = "ALL"
  }
  
  attribute {
    name = "event_type"
    type = "S"
  }
  
  tags = {
    Name = "User Logbook"
  }
}
