# IAM Role for External Secrets Operator in DRE Admin Cluster with an assume rule
# that allows the cluster to perform STS:AssumeRole.
resource "aws_iam_role" "ctrlplne_extsecrets" {
  name               = "${local.prefix}external-secrets-operator"
  description        = "Role for External Secrets Operator in EKS."
  path               = "/framework/"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json

  tags = local.tags
}

# IAM Role for AWS Load Balancer Controller.
resource "aws_iam_role" "aws_load_balancer_controller" {
  name               = "${local.prefix}aws-load-balancer-controller"
  description        = "Role for AWS Load Balancer Controller."
  path               = "/"

  assume_role_policy = templatefile("${path.module}/templates/iam_trust_aws_load_balancer_controller.json", {
      oidc_provider_arn = module.dre_crossplane_primary_1.oidc_provider_arn
      oidc_provider_url = trimprefix(module.dre_crossplane_primary_1.cluster_oidc_issuer_url, "https://")
  })
  depends_on = [
    module.dre_crossplane_primary_1
  ]

  tags = local.tags
}

# IAM Role for ArgoCD.
resource "aws_iam_role" "argocd" {
  name               = "${local.prefix}argocd"
  description        = "Role for ArgoCD."
  path               = "/"

  assume_role_policy = templatefile("${path.module}/templates/iam_trust_argocd.json", {
      oidc_provider_arn = module.dre_crossplane_primary_1.oidc_provider_arn
      oidc_provider_url = trimprefix(module.dre_crossplane_primary_1.cluster_oidc_issuer_url, "https://")
  })
  depends_on = [
    module.dre_crossplane_primary_1
  ]

  tags = local.tags
}

# Role for Crossplane AWS Provider.
resource "aws_iam_role" "crossplane_provider_aws" {
  name        = "${local.prefix}crossplane-provider-aws"
  description = "Role for Crossplane AWS Provider."
  path        = "/"

    assume_role_policy = templatefile("${path.module}/templates/iam_trust_crossplane_provider_aws.json", {
      oidc_provider_arn = module.dre_crossplane_primary_1.oidc_provider_arn
      oidc_provider_url = trimprefix(module.dre_crossplane_primary_1.cluster_oidc_issuer_url, "https://")
    })

  depends_on = [
    module.dre_crossplane_primary_1
  ]

  tags = local.tags
}

# IAM Role for Crosplane Terraform Provider.
resource "aws_iam_role" "crossplane_provider_terraform" {
  name        = "${local.prefix}crossplane-provider-terraform"
  description = "IAM Role for Crosplane Terraform Provider."
  path        = "/"

    assume_role_policy = templatefile("${path.module}/templates/iam_trust_crossplane_provider_tf.json", {
      oidc_provider_arn = module.dre_crossplane_primary_1.oidc_provider_arn
      oidc_provider_url = trimprefix(module.dre_crossplane_primary_1.cluster_oidc_issuer_url, "https://")
    })

  depends_on = [
    module.dre_crossplane_primary_1
  ]

  tags = local.tags
}

# Role for Crossplane AWS Provider.
resource "aws_iam_role" "external_dns" {
  name        = "${local.prefix}external-dns"
  description = "Role for external DNS to manage route53 records."
  path        = "/"

    assume_role_policy = templatefile("${path.module}/templates/iam_trust_external_dns.json", {
      oidc_provider_arn = module.dre_crossplane_primary_1.oidc_provider_arn
      oidc_provider_url = trimprefix(module.dre_crossplane_primary_1.cluster_oidc_issuer_url, "https://")
    })

  depends_on = [
    module.dre_crossplane_primary_1
  ]

  tags = local.tags
}
