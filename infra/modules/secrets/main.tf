variable "auth_db_secret_name" {}
variable "auth_jwt_secret_name" {}
variable "products_db_secret_name" {}
variable "products_jwt_secret_name" {}

variable "db_endpoint" {}
variable "db_name" {}
variable "db_user" {}
variable "db_password" {
  sensitive = true
}

resource "aws_secretsmanager_secret" "auth_db" {
  name = var.auth_db_secret_name
}

resource "aws_secretsmanager_secret_version" "auth_db_v" {
  secret_id = aws_secretsmanager_secret.auth_db.id
  secret_string = jsonencode({
    host     = var.db_endpoint
    database = var.db_name
    username = var.db_user
    password = var.db_password
  })
}

resource "aws_secretsmanager_secret" "auth_jwt" {
  name = var.auth_jwt_secret_name
}

resource "aws_secretsmanager_secret_version" "auth_jwt_v" {
  secret_id     = aws_secretsmanager_secret.auth_jwt.id
  secret_string = jsonencode({ secret = "CHANGE_ME_AUTH_JWT" })
}

resource "aws_secretsmanager_secret" "products_db" {
  name = var.products_db_secret_name
}

resource "aws_secretsmanager_secret_version" "products_db_v" {
  secret_id = aws_secretsmanager_secret.products_db.id
  secret_string = jsonencode({
    host     = var.db_endpoint
    database = var.db_name
    username = var.db_user
    password = var.db_password
  })
}

resource "aws_secretsmanager_secret" "products_jwt" {
  name = var.products_jwt_secret_name
}

resource "aws_secretsmanager_secret_version" "products_jwt_v" {
  secret_id     = aws_secretsmanager_secret.products_jwt.id
  secret_string = jsonencode({ secret = "CHANGE_ME_PRODUCTS_JWT" })
}

output "auth_db_secret_arn" {
  value = aws_secretsmanager_secret.auth_db.arn
}

output "auth_jwt_secret_arn" {
  value = aws_secretsmanager_secret.auth_jwt.arn
}

output "products_db_secret_arn" {
  value = aws_secretsmanager_secret.products_db.arn
}

output "products_jwt_secret_arn" {
  value = aws_secretsmanager_secret.products_jwt.arn
}
