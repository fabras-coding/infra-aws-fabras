###############################################
# ECS Cluster
###############################################

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

###############################################
# IAM Roles
###############################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.cluster_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.cluster_name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "${var.cluster_name}-task-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:*"]
        Resource = var.sqs_queue_arn
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:*"]
        Resource = var.dynamodb_table_arn
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [
          var.auth_db_secret_arn,
          var.auth_jwt_secret_arn,
          var.products_db_secret_arn,
          var.products_jwt_secret_arn
        ]
      }
    ]
  })
}

###############################################
# Security Group for ECS Tasks
###############################################

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.cluster_name}-ecs-tasks-sg"
  description = "Allow ECS tasks to receive traffic from ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###############################################
# Task Definition - AuthService
###############################################

resource "aws_ecs_task_definition" "auth" {
  family                   = "authservice"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "authservice"
      image     = "${var.auth_ecr_repo_url}:${var.auth_image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      secrets = [
        { name = "DB_CONNECTION", valueFrom = var.auth_db_secret_arn },
        { name = "JWT_SECRET", valueFrom = var.auth_jwt_secret_arn }
      ]
    }
  ])
}

###############################################
# Task Definition - Products API
###############################################

resource "aws_ecs_task_definition" "products" {
  family                   = "products-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "products-api"
      image     = "${var.products_ecr_repo_url}:${var.products_image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      secrets = [
        { name = "DB_CONNECTION", valueFrom = var.products_db_secret_arn },
        { name = "JWT_SECRET", valueFrom = var.products_jwt_secret_arn }
      ]
    }
  ])
}

###############################################
# ECS Services
###############################################

resource "aws_ecs_service" "auth" {
  name            = "authservice"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.auth.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.auth_tg.arn
    container_name   = "authservice"
    container_port   = 80
  }
}

resource "aws_ecs_service" "products" {
  name            = "products-api"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.products.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.products_tg.arn
    container_name   = "products-api"
    container_port   = 80
  }
}

###############################################
# Target Groups
###############################################

resource "aws_lb_target_group" "auth_tg" {
  name     = "authservice-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "products_tg" {
  name     = "products-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}
