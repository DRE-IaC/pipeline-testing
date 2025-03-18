# Make a data object for the AWS Managed Policy we want to attach.
data "aws_iam_policy" "ec2_ecr_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# Make a data object for the AWS Managed Policy we want to attach.
data "aws_iam_policy" "ec2_read_only_access" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# Make a data object for the AWS Managed Policy we want to attach.
data "aws_iam_policy" "s3_read_only_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Make a data object for the AWS Managed Policy we want to attach.
data "aws_iam_policy" "s3_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Make a data object for the AWS Managed Policy we want to attach.
data "aws_iam_policy" "ec2_ecr_read_access" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
# Make a data object for the current AWS user
data "aws_caller_identity" "current" {}

# Current region
data "aws_region" "current" {}

# Make a data object for the AWS Managed Policy we want to attach.
# Policy defined for Pdevops Service Account for Prisma Scans
# data "aws_iam_policy" "ec2_instance_profile_ecr_container_builds" {
#  arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
# }

# Make a data object for the AWS organization of the current user.
# Retrieves the AWS Organization's unique ID using the aws_organizations_organization data source, allowing only accounts within the organization to assume the ecr_reader IAM role.
# data "aws_organizations_organization" "current" {}

# Full access to IAM.
data "aws_iam_policy" "iam_full_access" {
  arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

# Access to Systems Manager service core functionality. Needed for EC2 Session Manager.
data "aws_iam_policy" "ssm_managed_instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
#To Get the Canonical Id of a User
data "aws_canonical_user_id" "current" {}

# Data object for the AWS managed policy for EBS CSI driver.
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Policy is used to allow a service account in the EKS cluster to assume a role
# in order to perform functions within AWS outside of the EKS cluster.
data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [module.dre_crossplane_primary_1.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = format("%s:aud", module.dre_crossplane_primary_1.oidc_provider)
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_eks_cluster" "main" {
  name = var.cluster_name

  depends_on = [
    module.dre_crossplane_primary_1
  ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name

  depends_on = [
    module.dre_crossplane_primary_1
  ]
}

# Data sources for addon versions
data "aws_eks_addon_version" "coredns" {
  addon_name         = "coredns"
  kubernetes_version = var.eks_version
  most_recent       = true
}

data "aws_eks_addon_version" "kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = var.eks_version
  most_recent       = true
}

data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = var.eks_version
  most_recent       = true
}

data "aws_eks_addon_version" "ebs_csi" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.eks_version
  most_recent       = true
}
