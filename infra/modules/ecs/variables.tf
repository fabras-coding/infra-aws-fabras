variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_arn" {
  type = string
}

variable "alb_security_group_id" {
  type = string
}

variable "auth_ecr_repo_url" {
  type = string
}

variable "products_ecr_repo_url" {
  type = string
}

variable "auth_db_secret_arn" {
  type = string
}

variable "auth_jwt_secret_arn" {
  type = string
}

variable "products_db_secret_arn" {
  type = string
}

variable "products_jwt_secret_arn" {
  type = string
}

variable "sqs_queue_arn" {
  type = string
}

variable "dynamodb_table_arn" {
  type = string
}

variable "auth_image_tag" {
  type = string
}

variable "products_image_tag" {
  type = string
}
