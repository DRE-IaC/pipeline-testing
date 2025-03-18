# Define the use2-iac-controlplane namespace
resource "kubernetes_namespace" "use2_iac_controlplane" {
  metadata {
    name = "use2-iac-controlplane"
  }
}

# Create the required configmaps before deploying the bootstrap required apps.
resource "kubernetes_config_map_v1" "live-aws-percipio-config" {
  for_each = toset([
    "live-aws-percipio-config", 
    "platform-config"
  ])
  metadata {
      name      = each.key
      namespace = "use2-iac-controlplane"
  }

  data = {
      "aws.irsa.argocd.arn"                        = "${aws_iam_role.argocd.arn}"
      "aws.irsa.aws-load-balancer-controller.arn"  = "${aws_iam_role.aws_load_balancer_controller.arn}"
      "aws.irsa.crossplane-provider-aws.arn"       = "${aws_iam_role.crossplane_provider_aws.arn}"
      "aws.irsa.crossplane-provider-terraform.arn" = "${aws_iam_role.crossplane_provider_terraform.arn}"
      "aws.irsa.external-dns.arn"                  = "${aws_iam_role.external_dns.arn}"
      "aws.irsa.external-secrets-operator.arn"     = "${aws_iam_role.ctrlplne_extsecrets.arn}"
      "cluster.name"                               = var.cluster_name
      "cluster.provider"                           = "eks"
      "cluster.region"                             = var.region
      "cluster.role"                               = "${split("-", var.cluster_name)[2]}"
      "environment.name"                           = "use2-iac"
      "environment.role"                           = var.environment_role
      "ingress.internal.zoneName"                  = ""
      "ingress.external.zoneName"                  = "controlplane.iac.percipio.com"
      "aws.alb.external.external_status_address"   = ""
      "aws.alb.internal.external_status_address"   = ""
      "aws.alb.restricted.external_status_address" = ""
      "velero.role.arn"                            = "${aws_iam_role.dre_iac_velero.arn}"
      "velero.bucket.name"                         = "${aws_s3_bucket.velero.id}"
  }
}
