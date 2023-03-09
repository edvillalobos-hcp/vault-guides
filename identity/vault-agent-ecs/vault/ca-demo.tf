resource "vault_mount" "root_ca" {
  path = "pki_root"
  type = "pki"
  default_lease_ttl_seconds = 8640000
  max_lease_ttl_seconds = 8640000
}

resource "vault_pki_secret_backend_root_cert" "root_cert" {
  depends_on = [
    vault_mount.root_ca
  ]
  backend = vault_mount.root_ca.path
  type = "internal"
  common_name = "testlab.com"
  ttl = "87600h"
  format = "pem"
  private_key_format = "der"
  key_type = "ec"
  key_bits = 256
  exclude_cn_from_sans = "true"
  organization = "Test Company"
}

resource "vault_pki_secret_backend_config_urls" "root_url" {
  backend = vault_mount.root_ca.path
  issuing_certificates = [ "${local.hcp_vault_public_endpoint}/v1/${vault_mount.root_ca.path}/ca" ]
  crl_distribution_points = [ "${local.hcp_vault_public_endpoint}/v1/${vault_mount.root_ca.path}/crl" ]
}

resource "vault_pki_secret_backend_crl_config" "crl_config" {
  backend = vault_mount.root_ca.path
  expiry = "26280h"
  disable = false
}

resource "vault_pki_secret_backend_role" "role" {
  backend = vault_mount.root_ca.path
  name = "test"

  allow_any_name = true
  enforce_hostnames = false
  allow_ip_sans = false
  server_flag = true
  client_flag = false
  max_ttl = "87600h"
  ttl = 120
  key_type = "ec"
  key_bits = 256

  key_usage = [
    "DigitalSignature",
    "KeyAgreement",
    "KeyEncipherment",
  ]
}

resource "vault_policy" "pki" {
  name   = "cert-pki"
  policy = <<EOT
path "pki_root/issue/test" {
    capabilities = [ "create", "update" ]
}

path "auth/token/renew" {
  capabilities = ["update"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}
EOT
}

resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "pki" {
  backend        = vault_auth_backend.approle.path
  role_name      = "vault-cert"
  token_policies = [vault_policy.pki.name]
  token_num_uses = 0
}

resource "vault_approle_auth_backend_role_secret_id" "pki" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.pki.role_name
}

data "vault_approle_auth_backend_role_id" "pki" {
  backend = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.pki.role_name
}

output "pki_secret_id" {
  value     = vault_approle_auth_backend_role_secret_id.pki.secret_id
  sensitive = true
}

output "pki_role_id" {
  value = data.vault_approle_auth_backend_role_id.pki.role_id
}