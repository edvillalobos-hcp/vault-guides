//--------------------------------------------------------------------
// Resources


# Vault Client IAM Config
resource "aws_iam_instance_profile" "vault-client" {
  name = "${var.environment_name}-vault-client-instance-profile"
  role = aws_iam_role.vault-client.name
}

resource "aws_iam_role" "vault-client" {
  name               = "${var.environment_name}-vault-client-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "vault-client" {
  name   = "${var.environment_name}-vault-client-role-policy"
  role   = aws_iam_role.vault-client.id
  policy = data.aws_iam_policy_document.vault-client.json
}

//--------------------------------------------------------------------
// Data Sources

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vault-client" {
  statement {
    sid    = "RaftSingle"
    effect = "Allow"

    actions = ["ec2:DescribeInstances"]

    resources = ["*"]
  }
}

