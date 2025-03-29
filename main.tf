/**
 * main.tf
 * Main entrypoint for the environment. `infrastructure` module creates all of the resources required to build out the
 * infrastructure required for a single reigon.
 */

provider "aws" {
  region  = var.region
  profile = var.profile

  assume_role {
    role_arn = var.assume_role_arn
  }
}

provider "kubernetes" {
  host                   = module.dre_crossplane_primary_1.cluster_endpoint
  cluster_ca_certificate = base64decode(module.dre_crossplane_primary_1.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = [
      "eks", "get-token", "--profile", var.profile, "--cluster-name",
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
      "eks", "get-token", "--profile", var.profile, "--cluster-name",
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
  host                   = module.dre_crossplane_primary_1.cluster_endpoint
  cluster_ca_certificate = base64decode(module.dre_crossplane_primary_1.cluster_certificate_authority_data)
  exec {
    command     = "aws"
    args        = [
      "eks", "get-token", "--profile", var.profile, "--cluster-name",
      data.aws_eks_cluster.main.name, "--region", var.region
    ]
    api_version = "client.authentication.k8s.io/v1beta1"
  }
}
