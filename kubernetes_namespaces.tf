# Create the required namespaces before deploying the bootstrap required apps.

resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = var.external_secrets_namespace
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = var.cert_manager_namespace
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}
