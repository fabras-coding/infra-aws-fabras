variable "vpc_id" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "alb_name" {}

resource "aws_security_group" "alb_sg" {
  name        = "${var.alb_name}-sg"
  description = "ALB SG"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "this" {
  name               = var.alb_name
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
}

output "alb_arn" {
  value = aws_lb.this.arn
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}
