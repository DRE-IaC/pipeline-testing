module "dre_crossplane_primary_1" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24.2"

  cluster_name = var.cluster_name

  cluster_version                 = var.eks_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # Cut down the amount of logs stored.
  cloudwatch_log_group_retention_in_days = 7

  vpc_id                   = module.dre_crossplane_primary_vpc.vpc_id
  subnet_ids               = module.dre_crossplane_primary_vpc.private_subnets
  control_plane_subnet_ids = module.dre_crossplane_primary_vpc.intra_subnets

  # Limit the logging happening in the control plane.
  cluster_enabled_log_types = ["authenticator", "api"]

  # Create OpenID Connect Provider for EKS to enable IRSA.
  enable_irsa = true

  cluster_addons = {
    coredns = {
      version = data.aws_eks_addon_version.coredns.version
    }
    kube-proxy = {
      version = data.aws_eks_addon_version.kube_proxy.version
    }
    aws-ebs-csi-driver = {
      version = data.aws_eks_addon_version.ebs_csi.version
    }
    vpc-cni = {
      version = data.aws_eks_addon_version.vpc_cni.version
      before_compute = true
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  # Enable EFA support by adding necessary security group rules
  # to the shared node security group
  enable_efa_support = true

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    disk_size = 100
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    # AL2023 node group utilizing new user data format which utilizes nodeadm
    # to join nodes to the cluster (instead of /etc/eks/bootstrap.sh)
    al2023_nodeadm = {
      ami_type = "AL2023_x86_64_STANDARD"
      platform = "al2023"

      use_latest_ami_release_version = true

      cloudinit_pre_nodeadm = [
        {
          content_type = "application/node.eks.aws"
          content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              kubelet:
                config:
                  shutdownGracePeriod: 30s
                  featureGates:
                    DisableKubeletCloudCredentialProviders: true
          EOT
        }
      ]
      min_size     = var.eks_primary_nodes_min_size
      max_size     = var.eks_primary_nodes_max_size
      desired_size = var.eks_primary_nodes_desired
      tags         = var.tags
    }
  }
  tags = merge(var.tags, {
    eks-cluster = var.cluster_name
  })
}

module "dre_crossplane_primary_auth_1" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.24.2"

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/dre-delivery"
      username = "dre-delivery"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::565393059711:role/AWSReservedSSO_CoreIaCTeamAccess_b2ccc40d8da4ab22"
      username = "iac-eks-admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::565393059711:role/iac-admin"
      username = "iac-eks-admin"
      groups   = ["system:masters"]
    }
  ]

  depends_on = [
    module.dre_crossplane_primary_1
  ]
}

