## Install External Secrets Operator via Helm chart.
## We are doing this in Terraform because you need an AWS Secret Key and Access
## generated that can be used by the External Secrets operator to pull secrets.
## Therefore this exists in Terraform so we can handle the creation of the account
## and pass the credentials.
#
resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = var.external_secrets_namespace
  create_namespace = true

  values = [
    templatefile("${path.module}/kubernetes/cert-manager/cert-manager-values.yaml", {
      rolearn = aws_iam_role.ctrlplne_extsecrets.arn
    })
  ]

  lifecycle {
    ignore_changes = [version, set, values]
  }

  depends_on = [
    kubernetes_namespace.external_secrets,
    helm_release.cert_manager
  ]
}

resource "kubectl_manifest" "external_secrets_cluster_secret_store" {
  yaml_body  = templatefile("${path.module}/kubernetes/external-secrets/external-secrets-cluster-secret-store.yaml", {
    namespace      = var.external_secrets_namespace
    region         = var.region
    serviceaccount = var.external_secrets_kubernetes_sa_name
  })
  depends_on = [helm_release.external_secrets]
}
