output "endpoints" {
  value = <<EOF
   ssh -i ${var.key_name}.pem ubuntu@${aws_instance.vault-client.public_ip}
EOF

}

output "instance-public-ip" {
  value = aws_instance.vault-client.public_ip
}
output "instance-private-ip" {
  value = aws_instance.vault-client.private_ip
}
output "Instance-IAM-role" {
  value = aws_iam_role.vault-client.arn
}