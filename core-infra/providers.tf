terraform {
  backend "s3" {
    bucket = "ephemeral-backend-khushal"
    key    = "core-infra/lambda-cleanup.tfstate"
    region = "us-east-1"
  }
}