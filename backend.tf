terraform {
  cloud {
    organization = "example-org-3dd2d6"

    workspaces {
      name = "tf-indico"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
  }
  
  required_version = ">= 1.1.2"
}

provider "aws" {
  region = var.region
}