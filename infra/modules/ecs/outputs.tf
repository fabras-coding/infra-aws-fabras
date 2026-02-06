output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "auth_service_name" {
  value = aws_ecs_service.auth.name
}

output "products_service_name" {
  value = aws_ecs_service.products.name
}
