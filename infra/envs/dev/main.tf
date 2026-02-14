terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
module "vpc" {
  source = "../../modules/vpc"

  name       = "fabras-dev-vpc"
  cidr_block = "10.0.0.0/16"
}

# ECR
module "ecr" {
  source = "../../modules/ecr"

  repositories = [
    "fabras-authservice",
    "fabras-products"
  ]
}

# RDS (compartilhado entre AuthService e Products)
module "rds" {
  source = "../../modules/rds"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  db_name            = "appdb"
  username           = var.db_username
  password           = var.db_password
}

# Secrets Manager
module "secrets" {
  source = "../../modules/secrets"

  auth_db_secret_name      = "authservice/db"
  auth_jwt_secret_name     = "authservice/jwt"
  products_db_secret_name  = "products/db"
  products_jwt_secret_name = "products/jwt"

  db_endpoint = module.rds.db_endpoint
  db_name     = module.rds.db_name
  db_user     = var.db_username
  db_password = var.db_password
}

# DynamoDB
module "dynamodb" {
  source = "../../modules/dynamodb"

  table_name = "ProductStock"
}

# SQS
module "sqs" {
  source = "../../modules/sqs"

  queue_name = "product-created"
}

# ALB
module "alb" {
  source            = "../../modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_name          = "fabras-dev-alb"
  auth_tg_arn       = module.ecs.auth_tg_arn
  products_tg_arn   = module.ecs.products_tg_arn
}

# ECS Cluster + Services
module "ecs" {
  source = "../../modules/ecs"

  cluster_name = "fabras-dev-cluster"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  alb_arn               = module.alb.alb_arn
  alb_security_group_id = module.alb.alb_sg_id

  auth_ecr_repo_url     = module.ecr.repositories["fabras-authservice"]
  products_ecr_repo_url = module.ecr.repositories["fabras-products"]

  auth_db_secret_arn      = module.secrets.auth_db_secret_arn
  auth_jwt_secret_arn     = module.secrets.auth_jwt_secret_arn
  products_db_secret_arn  = module.secrets.products_db_secret_arn
  products_jwt_secret_arn = module.secrets.products_jwt_secret_arn

  sqs_queue_arn      = module.sqs.queue_arn
  dynamodb_table_arn = module.dynamodb.table_arn

  auth_image_tag     = var.auth_image_tag
  products_image_tag = var.products_image_tag

  auth_tg_arn     = module.ecs.auth_tg_arn
  products_tg_arn = module.ecs.products_tg_arn
}

# S3 para React (deploy depois)
module "s3_static_site" {
  source = "../../modules/s3_static_site"

  bucket_name = "fabras-react-client-dev"
}
