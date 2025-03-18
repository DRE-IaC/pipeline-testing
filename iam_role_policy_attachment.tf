# IAM Role Policy attachment for External Secrets Operator.
resource "aws_iam_role_policy_attachment" "external_secrets_manager_access" {
  role       = aws_iam_role.ctrlplne_extsecrets.name
  policy_arn = aws_iam_policy.secrets_manager_read.arn
}

# IAM Role Policy attachment for AWS Load Balancer Controller.
resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

# IAM Role Policy attachment for ArgoCD.
resource "aws_iam_role_policy_attachment" "argocd" {
  role       = aws_iam_role.argocd.name
  policy_arn = aws_iam_policy.argocd.arn
}

# IAM Role Policy attachment for Crossplane AWS Provider.
resource "aws_iam_role_policy_attachment" "crossplane_provider_aws" {
  role       = aws_iam_role.crossplane_provider_aws.name
  policy_arn = aws_iam_policy.crossplane_provider_aws.arn
}

# IAM Role Policy attachment for Crossplane Terraform Provider.
resource "aws_iam_role_policy_attachment" "crossplane_provider_terraform" {
  role       = aws_iam_role.crossplane_provider_terraform.name
  policy_arn = aws_iam_policy.crossplane_provider_terraform.arn
}

# IAM Role Policy attachment for Crossplane Terraform Provider.
resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}
