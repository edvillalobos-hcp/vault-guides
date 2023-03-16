//--------------------------------------------------------------------
// Providers

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

  cloud {
    organization = "Demo-Org-EV"

    workspaces {
      name = "vault-agent-linux-client"
    }
  }
}


provider "aws" {
  // Credentials set via env vars

  region = var.aws_region
}

provider "vault" {
  address   = local.hcp_vault_public_endpoint
  token     = local.hcp_vault_admin_token
  namespace = local.hcp_vault_namespace
}