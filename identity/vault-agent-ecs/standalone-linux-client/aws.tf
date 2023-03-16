
//--------------------------------------------------------------------
// Data Sources

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

//--------------------------------------------------------------------
// Vault Client Instance

resource "aws_instance" "vault-client" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = local.public_subnets
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.testing.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.vault-client.id

  tags = {
    Name     = "${var.environment_name}-vault-client"
  }

  user_data = data.template_file.vault-client.rendered

  lifecycle {
    ignore_changes = [
      ami,
      tags,
    ]
  }
}

data "template_file" "vault-client" {
  template = file("${path.module}/templates/userdata-vault-client.tpl")

  vars = {
    tpl_vault_zip_file     = var.vault_zip_file
    tpl_vault_service_name = "vault-${var.environment_name}"
    tpl_vault_server_addr  = local.hcp_vault_public_endpoint
  }
}