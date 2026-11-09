# Terraform and AWS provider requirements for the ansible-adhoc-lab (Abhinav T).
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "dmi-week9-ansible-adhoc-lab"
      Owner     = "Abhinav T"
      ManagedBy = "terraform"
    }
  }
}
