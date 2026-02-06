terraform {
  backend "s3" {
    bucket = "fabras-terraform-state"
    key    = "infra/dev/terraform.tfstate"
    region = "us-east-1"
  }
}
