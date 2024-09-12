terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # Terraform backend as s3 for Remote State Storage
  # CLI command: aws s3api put-object --bucket duongdx-terraform-state --key jenkins-nexus-ansible-docker-terraform/dev

  backend "s3" {
    bucket = "duongdx-terraform-state"
    key    = "jenkins-nexus-ansible-docker-terraform/dev/terraform.tfstate"
    region = "ap-southeast-1"

    # DynamoDB for state locking
    # dynamodb_table = "eks-cluster-dev"
  }

  # required_providers {
  #   kubernetes = {
  #     source  = "hashicorp/kubernetes"
  #     version = ">= 2.31.0"
  #   }
  # }
}

# Provider Block
provider "aws" {
  region  = var.aws_region
  profile = "default"
}
