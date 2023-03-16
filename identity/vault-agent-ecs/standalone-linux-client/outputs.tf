output "endpoints" {
  value = <<EOF

Vault Client IP (public):  ${aws_instance.vault-client.public_ip}
Vault Client IP (private): ${aws_instance.vault-client.private_ip}

For example:
   ssh -i ${var.key_name}.pem ubuntu@${aws_instance.vault-client.public_ip}

Vault Client IAM Role ARN: ${aws_iam_role.vault-client.arn}

EOF

}
