variable "vpc_id" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "db_name" {}
variable "username" {}
variable "password" {
  sensitive = true
}

resource "aws_db_subnet_group" "this" {
  name       = "fabras-dev-db-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "db_sg" {
  name        = "fabras-dev-db-sg"
  description = "DB SG"
  vpc_id      = var.vpc_id
}

resource "aws_db_instance" "this" {
  identifier        = "fabras-dev-db"
  engine            = "sqlserver-ex"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = var.db_name
  username = var.username
  password = var.password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  skip_final_snapshot = true
}

output "db_endpoint" {
  value = aws_db_instance.this.address
}

output "db_name" {
  value = aws_db_instance.this.db_name
}
