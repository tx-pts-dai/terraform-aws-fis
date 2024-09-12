terraform {
  required_version = ">= 1.0.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

data "aws_caller_identity" "current" {}