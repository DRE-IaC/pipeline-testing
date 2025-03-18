## Install ArgoCD via Helm chart.

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  # It's good practice to set up a namespace for the release
  namespace        = var.argocd_namespace
  create_namespace = false

  values = [file("${path.module}/kubernetes/argocd/argocd-values.yaml")]

  lifecycle {
    ignore_changes = [version, set, values]
  }

  depends_on = [
    kubernetes_namespace.argocd,
    helm_release.external_secrets,
    helm_release.cert_manager
  ]
}

resource "kubectl_manifest" "argocd_external_secret" {
  yaml_body  = templatefile("${path.module}/kubernetes/argocd/external-secret-github.yaml", {
    namespace = var.argocd_namespace
    regionprefix = "${split("-", var.cluster_name)[0]}"
    environmentrole = "${split("-", var.cluster_name)[1]}"
  })

  depends_on = [
    kubernetes_namespace.argocd,
    helm_release.argocd,
    helm_release.external_secrets
  ]
}

resource "kubectl_manifest" "argocd_application" {
  yaml_body  = templatefile("${path.module}/kubernetes/argocd/argo-application.yaml", {
    namespace = var.argocd_namespace
    environmentname = "${split("-", var.cluster_name)[0]}-${split("-", var.cluster_name)[1]}"
  })
  depends_on = [
    kubectl_manifest.argocd_external_secret
  ]
}

resource "kubectl_manifest" "argocd_download_tools" {
  yaml_body  = templatefile("${path.module}/kubernetes/argocd/download-tools.yaml", {
    namespace = var.argocd_namespace
  })
  depends_on = [
    kubernetes_namespace.argocd
  ]
}

resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
}
}

resource "kubectl_manifest" "velero" {
  yaml_body  = templatefile("${path.module}/kubernetes/velero/application.yaml", {
    namespace = "velero"
    environmentname = "${split("-", var.cluster_name)[0]}-${split("-", var.cluster_name)[1]}"
  })

    depends_on = [
    kubernetes_namespace.velero
  ]
}
