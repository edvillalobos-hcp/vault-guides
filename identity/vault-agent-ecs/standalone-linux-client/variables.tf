data "terraform_remote_state" "vault-agent-ecs-infra" {
  backend = "remote"

  config = {
    organization = "Demo-Org-EV"
    workspaces = {
      name = "vault-agent-ecs-infra"
    }
  }
}

# AWS region and AZs in which to deploy
variable "aws_region" {
  default = "us-east-1"
}

variable "availability_zones" {
  default = "us-east-1a"
}

# All resources will be tagged with this
variable "environment_name" {
  default = "vault-agent-demo"
}

# URL for Vault OSS binary
variable "vault_zip_file" {
  default = "https://releases.hashicorp.com/vault/1.13.0/vault_1.13.0_linux_amd64.zip"
}

# Instance size
variable "instance_type" {
  default = "t2.micro"
}

# SSH key name to access EC2 instances (should already exist) in the AWS Region
variable "key_name" {
}

variable "hcp_vault_admin_token" {
  type        = string
  description = "HCP Vault Cluster token for configuration"
  default     = ""
  sensitive   = true
}

locals {
  #region                           = var.region == "" ? data.terraform_remote_state.vault-agent-ecs-infra.outputs.region : var.region
  public_subnets  = data.terraform_remote_state.vault-agent-ecs-infra.outputs.public_subnets
  vpc_id  = data.terraform_remote_state.vault-agent-ecs-infra.outputs.vpc_id
  hcp_vault_public_endpoint  = data.terraform_remote_state.vault-agent-ecs-infra.outputs.hcp_vault_public_endpoint
  #hcp_vault_private_endpoint = data.terraform_remote_state.vault-agent-ecs-infra.outputs.hcp_vault_private_endpoint
  #hcp_vault_namespace       = data.terraform_remote_state.vault-agent-ecs-infra.outputs.hcp_vault_namespace
  hcp_vault_admin_token   = var.hcp_vault_admin_token == "" ? data.terraform_remote_state.vault-agent-ecs-infra.outputs.hcp_vault_admin_token : var.hcp_vault_admin_token
}