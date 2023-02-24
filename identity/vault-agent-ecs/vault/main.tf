terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.72"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}

provider "vault" {
  address   = local.hcp_vault_public_endpoint
  token     = local.hcp_vault_admin_token
  namespace = local.hcp_vault_namespace
}