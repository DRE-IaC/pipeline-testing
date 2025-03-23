/**
 * main.tf
 * Main entrypoint for the environment. `infrastructure` module creates all of the resources required to build out the
 * infrastructure required for a single reigon.
 */

provider "aws" {
  region = var.region
  # Removed profile and assume_role as GitHub Actions already has the credentials
}

provider "kubernetes" {
  host                   = module.dre_crossplane_primary_1.cluster_endpoint
  cluster_ca_certificate = base64decode(module.dre_crossplane_primary_1.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = [
      "eks", "get-token", "--cluster-name",
      data.aws_eks_cluster.main.name, "--region", var.region
    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.dre_crossplane_primary_1.cluster_endpoint
    cluster_ca_certificate = base64decode(module.dre_crossplane_primary_1.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args        = [
        "eks", "get-token", "--cluster-name",
        data.aws_eks_cluster.main.name, "--region", var.region
      ]
    }
  }
}

# Kubectl provider was added to a limitation of the Terraform Kubernetes module
# which requires API access during the Terraform Plan stage to the cluster
# to apply a manifest. Since the cluster does not exist yet, you cannot
# have API access. This plugin required v1beta1 api version.
provider "kubectl" {
  # Configuration options
  host                   = module.dre_crossplane_primary_1.cluster_endpoint
  cluster_ca_certificate = base64decode(module.dre_crossplane_primary_1.cluster_certificate_authority_data)
  exec {
    command     = "aws"
    args        = [
      "eks", "get-token", "--cluster-name",
      data.aws_eks_cluster.main.name, "--region", var.region
    ]
    api_version = "client.authentication.k8s.io/v1beta1"
  }
}