# IAM Policy for External Secrets Operator.
resource "aws_iam_policy" "secrets_manager_read" {
  name        = "${local.prefix}secretsmanager-read"
  path        = "/"
  description = "Policy to allow reading Secrets."

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets",
          "secretsmanager:DescribeSecret",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
  tags = local.tags
}

# IAM Policy for AWS Load Balancer Controller.
resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${local.prefix}aws-load-balancer-controller"
  path        = "/"
  description = "Policy for AWS Load Balancer Controller."

  policy = file("${path.module}/templates/aws_load_balancer_controller.json.tpml")

  tags = local.tags
}

# IAM Policy for ArgoCD.
resource "aws_iam_policy" "argocd" {
  name        = "${local.prefix}argocd"
  path        = "/"
  description = "Policy for ArgoCD."

  policy = file("${path.module}/templates/assume_role.json.tmpl")

  tags = local.tags
}

# IAM Policy for Crossplane AWS Provider.
resource "aws_iam_policy" "crossplane_provider_aws" {
  name        = "${local.prefix}crossplane-provider-aws"
  path        = "/"
  description = "Policy for Crossplane AWS Provider."

  policy = file("${path.module}/templates/assume_role.json.tmpl")

  tags = local.tags
}

# IAM Policy for Crossplane Terraform Provider.
resource "aws_iam_policy" "crossplane_provider_terraform" {
  name        = "${local.prefix}crossplane-provider-terraform"
  path        = "/"
  description = "Policy for Crossplane Terraform Provider."

  policy = file("${path.module}/templates/assume_role.json.tmpl")

  tags = local.tags
}

# IAM Policy for Crossplane Terraform Provider.
resource "aws_iam_policy" "external_dns" {
  name        = "${local.prefix}external-dns"
  path        = "/"
  description = "Policy for ExternalDNS"

  policy = file("${path.module}/templates/external_dns.json.tmpl")

  tags = local.tags
}