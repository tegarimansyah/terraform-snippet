terraform {
  backend "s3" {
    bucket         = "ecom-ai-test-tfstate"
    region         = "us-east-1"
    key            = "ecom-ai-test.tfstate"
    encrypt        = true
    dynamodb_table = "ecom-ai-test-tfstate-lock"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20"
    }
  }

  required_version = ">= 1.1.0"
}

provider "aws" {
  region = var.region
}