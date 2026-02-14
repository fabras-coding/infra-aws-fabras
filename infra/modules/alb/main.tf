variable "vpc_id" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "alb_name" {}
variable "auth_tg_arn" {
  description = "ARN do Target Group do AuthService"
  type        = string
}
variable "products_tg_arn" {
  description = "ARN do Target Group do Products API"
  type        = string
}

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

# Listener para AuthService
resource "aws_lb_listener" "auth_listener" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.auth_tg_arn
  }
}

# Listener para Products API (exemplo: porta 81, ajuste conforme necessário)
resource "aws_lb_listener" "products_listener" {
  load_balancer_arn = aws_lb.this.arn
  port              = 81
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.products_tg_arn
  }
}

output "alb_arn" {
  value = aws_lb.this.arn
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}
