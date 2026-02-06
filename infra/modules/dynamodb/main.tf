variable "table_name" {}

resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "productId"
  range_key = "updatedAt"

  attribute {
    name = "productId"
    type = "S"
  }

  attribute {
    name = "updatedAt"
    type = "S"
  }
}

output "table_arn" {
  value = aws_dynamodb_table.this.arn
}
output "table_name" {
  value = aws_dynamodb_table.this.name
}