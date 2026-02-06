variable "repositories" {
  type = list(string)
}

resource "aws_ecr_repository" "this" {
  for_each = toset(var.repositories)

  name                 = each.value
  image_tag_mutability = "MUTABLE"
}

output "repositories" {
  value = {
    for name, repo in aws_ecr_repository.this :
    name => repo.repository_url
  }
}
