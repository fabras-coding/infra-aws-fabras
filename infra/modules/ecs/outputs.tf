output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "auth_tg_arn" {
  value = aws_lb_target_group.auth_tg.arn
}

output "products_tg_arn" {
  value = aws_lb_target_group.products_tg.arn
}

output "auth_service_name" {
  value = aws_ecs_service.auth.name
}

output "products_service_name" {
  value = aws_ecs_service.products.name
}
