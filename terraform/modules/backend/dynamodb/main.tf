locals {
  table_name = var.project
}

resource "aws_dynamodb_table" "main" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "area"
    type = "S"
  }

  global_secondary_index {
    name            = "gsi_area"
    hash_key        = "area"
    projection_type = "ALL"
  }
}
