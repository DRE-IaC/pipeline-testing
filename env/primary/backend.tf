terraform {
  required_version = ">= 1.3.2"
  backend "s3" {
    bucket         = "use2-iac-controlplane-tf-states-snarrabelly"
    key            = "primary/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.79.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = ">= 2.13"
    }
  }
}
