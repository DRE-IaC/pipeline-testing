/**
 * outputs.tf
 * Provides output variables for the module. Typically outputs names, identifiers, ARNs that are dynamically created and
 * would be required for other modules or connectivity with something else (such as unit tests).
 */

output "caller_account" {
  value = data.aws_caller_identity.current.account_id
}

output "region" {
  value = data.aws_region.current
}

output "eks_addon_versions" {
  description = "Versions of EKS addons being used"
  value = {
    coredns            = data.aws_eks_addon_version.coredns.version
    kube_proxy         = data.aws_eks_addon_version.kube_proxy.version
    vpc_cni            = data.aws_eks_addon_version.vpc_cni.version
    aws_ebs_csi_driver = data.aws_eks_addon_version.ebs_csi.version
  }
}
