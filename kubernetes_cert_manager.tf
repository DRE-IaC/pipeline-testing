# Install Cert Manager Operator via Helm chart.

resource "helm_release" "cert_manager" {
  depends_on = [
    kubernetes_namespace.cert_manager
  ]
  name             = "cert-manager"
  create_namespace = false
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = var.cert_manager_namespace

  set {
    name  = "installCRDs"
    value = "true"
  }
  set {
    name  = "global.leaderElection.namespace"
    value = "cert-manager"
  }
  set {
    name  = "startupapicheck.enabled"
    value = "False"
  }

  lifecycle {
    ignore_changes = [version, set, values]
  }
}

resource "kubectl_manifest" "cert_manager_cert_issuer" {
  yaml_body  = file("${path.module}/kubernetes/cert-manager/cert-manager-certissuer.yaml")
  depends_on = [helm_release.cert_manager]
}
