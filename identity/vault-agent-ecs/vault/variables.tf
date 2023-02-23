data "terraform_remote_state" "vault-agent-ecs-infra" {
  backend = "remote"

  config = {
    organization = "Demo-Org-EV"
    workspaces = {
      name = "vault-agent-ecs-infra"
    }
  }
}

variable "name" {
  type        = string
  description = "Name for infrastructure resources"
  default     = "learn"
}

variable "tags" {
  type        = map(string)
  description = "Tags to add to infrastructure resources"
  default     = {}
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
  validation {
    condition     = contains(["us-east-1", "us-west-2"], var.region)
    error_message = "Region must be a valid one for HCP."
  }
}


variable "product_db_hostname" {
  type        = string
  description = "Amazon RDS database hostname"
}

variable "product_db_port" {
  type        = number
  description = "Amazon RDS database port"
  default     = 5432
}

variable "product_db_username" {
  type        = string
  description = "Amazon RDS database username"
}


variable "product_db_password" {
  type        = string
  description = "Amazon RDS database password"
  sensitive   = true
}

variable "product_api_efs_access_point_arn" {
  type        = string
  description = "ARN for EFS Access Point of product-api"
}

variable "hcp_vault_cluster_id" {
  type        = string
  description = "HCP Vault Cluster ID for configuration"
  default     = ""
}

variable "hcp_vault_admin_token" {
  type        = string
  description = "HCP Vault Cluster token for configuration"
  default     = ""
  sensitive   = true
}

locals {
    tags = merge(var.tags, {
    Service = "hashicups"
    Purpose = "learn vault-agent-ecs"
  })
  #name                             = data.terraform_remote_state.vault-agent-ecs-infra.outputs.name
  #ecs_cluster                      = data.terraform_remote_state.vault-agent-ecs-infra.outputs.ecs_cluster
  region                           = var.region == "" ? data.terraform_remote_state.vault-agent-ecs-infra.outputs.region : var.region
  #url                              = data.terraform_remote_state.vault-agent-ecs-infra.outputs.boundary_endpoint
  product_database_username         = data.terraform_remote_state.vault-agent-ecs-infra.outputs.product_database_username
  product_database_hostname        = data.terraform_remote_state.vault-agent-ecs-infra.outputs.product_database_hostname
  product_database_password        = data.terraform_remote_state.vault-agent-ecs-infra.outputs.product_database_password
  product_api_efs_access_point_arn = data.terraform_remote_state.vault-agent-ecs-infra.outputs.product_api_efs_access_point_arn
  product_api_efs_access_point_id         = data.terraform_remote_state.vault-agent-ecs-infra.outputs.product_api_efs_access_point_id
  product_api_endpoint       = data.terraform_remote_state.vault-agent-ecs-infra.outputs.product_api_endpoint
  target_group_arn          = data.terraform_remote_state.vault-agent-ecs-infra.outputs.target_group_arn
  hcp_vault_cluster_id      = var.hcp_vault_cluster_id == "" ? data.terraform_remote_state.vault-agent-ecs-infra.outputs.hcp_vault_cluster : var.hcp_vault_cluster_id
  hcp_vault_public_endpoint  = data.terraform_remote_state.vault-agent-ecs-infra.outputs.hcp_vault_public_endpoint
  hcp_vault_private_endpoint = data.terraform_remote_state.vault-agent-ecs-infra.outputs.hcp_vault_private_endpoint
  hcp_vault_namespace       = data.terraform_remote_state.vault-agent-ecs-infra.outputs.hcp_vault_namespace
  hcp_vault_admin_token   = var.hcp_vault_admin_token == "" ? data.terraform_remote_state.vault-agent-ecs-infra.outputs.hcp_vault_admin_token : var.hcp_vault_admin_token
}