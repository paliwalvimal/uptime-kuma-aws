terraform {
  required_version = ">= 1.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.35.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.8.1"
    }
  }
}
