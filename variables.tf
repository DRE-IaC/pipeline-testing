/**
 * variables.tf
 * Defines variables (inputs) that the administrative environment can take.
 */

# Common environmental configuration.
variable "environment" {
  type        = string
  default     = "integration"
  description = "The environment this lives within, usually primary for production, mostly affects tags."
}

variable "region" {
  type        = string
  default     = "us-east-2"
  description = "The region to deploy the environment to."
}

variable "profile" {
  type        = string
  default     = ""
  description = "The pre-configured AWS profile to use to deploy to AWS."
}

variable "assume_role_arn" {
  type        = string
  default     = ""
  description = "The ARN of the role to assume when deploying the dre environment."
}

variable "tags" {
  type    = map(string)
  default = {
    Name = "iac-controlplane"
    CreatedBy = "Terraform"
  }
  description = "Tags that will be added to every possible resources within the environment. These tags always have a lower priority than tags defined in resources and modules."
}

variable "cluster_name" {
  type    = string
  default = "use2-iac-controlplane"
  description = "The name of the cluster."
}

variable "iac_percipio_domain" {
  type        = string
  default     = "iac.percipio.com"
  description = "Primary DNS zone delegated from the percipio.com"
}

variable "eks_version" {
  type    = string
  default = "1.31"
}

# VPC related variables.
variable "base_cidr_use2_controlplane_primary" {
  description = "Base CIDR address for the Control Plane VPC"
  type        = string
  default     = "10.78.64.0/20"
}

# Creates x.x.71.0, x.x.72.0, x.x.73.0 subnets.
variable "azs_public" {
  type    = map(number)
  default = {
    a = 7
    b = 8
    c = 9
  }
}

# Creates x.x.74.0, x.x.75.0, x.x.76.0 subnets.
variable "azs_private" {
  type    = map(number)
  default = {
    a = 10
    b = 11
    c = 12
  }
}

# The desired size of the primary EKS cluster.
variable "eks_primary_nodes_desired" {
  type    = number
  default = 3
}

# The min size of the primary EKS cluster.
variable "eks_primary_nodes_min_size" {
  type    = number
  default = 3
}

# The max size of the primary EKS cluster.
variable "eks_primary_nodes_max_size" {
  type    = number
  default = 5
}

# This variable is used to determine if we are deploying to a sandbox. It is
# a conditional to use in resources with counts.
variable "sandbox" {
  type    = bool
  default = false
}

# This is a variable to contain the list of IP ranges that are for Zscaler,
# Cisco VPN, and On-prem data centers.
variable "inbound_allowable_restricted_ip_ranges_0" {
  type    = list(string)
  default = [
    "80.169.219.40/29",
    "216.155.110.0/24",
    "10.80.80.30/32",
    "52.138.202.144/29",
    "52.170.185.240/29",
    "52.204.18.41/32",
    "62.23.74.200/29",
    "182.72.240.108/30",
    "170.52.44.50/32",
    "192.190.134.0/23",
    "67.132.9.0/24",
    "20.219.62.78/32",
    "62.180.27.100/32",
    "216.205.88.51/32",
    "69.74.157.160/30",
    "182.72.157.228/30",
    "213.86.21.208/29",
    "20.235.119.8/29",
    "3.139.17.165/32",
    "10.80.71.10/32",
    "54.81.239.135/32",
    "62.17.135.1/32",
    "209.251.156.0/24",
    "80.169.57.232/29",
    "216.205.88.50/32",
    "18.207.78.180/32",
    "10.80.70.30/32",
    "50.233.203.28/30",
    "18.204.178.169/32",
  ]
}

# This is a variable to contain the list of IP ranges that are for Zscaler,
# Cisco VPN, and On-prem data centers.
variable "inbound_allowable_restricted_ip_ranges_1" {
  type    = list(string)
  default = [
    "54.155.217.229/32",
    "54.228.129.169/32",
    "54.78.12.85/32",
    "54.78.140.66/32",
    "34.210.41.162/32",
    "34.214.246.8/32",
    "34.217.234.156/32",
    "34.218.214.25/32",
    "34.238.68.243/32",
    "185.199.108.0/22",
    "192.30.252.0/22",
    "140.82.112.0/20",
    "143.55.64.0/20",
    "65.121.228.0/24",
    "44.208.175.36/32",
    "54.157.142.80/32",
    "34.225.207.208/32",
  ]
}

# This is a variable to contain the list of IP ranges that are for Zscaler,
# Cisco VPN, and On-prem data centers.
variable "inbound_allowable_restricted_ip_ranges_ipv6" {
  type    = list(string)
  default = [
    "2606:50c0::/32",
    "2a0a:a440::/29",
  ]
}

# This is a variable to contain the list of IP ranges that are for Zscaler,
# Cisco VPN, and On-prem data centers.
variable "inbound_allowable_restricted_ip_ranges_2" {
  type    = list(string)
  default = [
    "3.132.92.81/32",
    "34.206.224.97/32",
    "50.233.202.220/30",
    "34.199.171.254/32",
    "203.197.245.0/24",
    "20.25.105.166/32",
    "54.225.57.206/32",
    "10.80.81.10/32",
    "207.179.182.176/29",
    "34.226.178.43/32",
    "67.129.215.8/29",
    "59.163.117.0/24",
    "3.93.133.72/32",
    "20.234.125.248/32",
  ]
}

variable "aws_secret_name" {
  description = "The name of the AWS Secret to create."
  type        = list(string)
  default = [
    "argocd-github-credentials/sshPrivateKey",
    "argocd-oidc-azure-clientSecret",
    "provider-terraform-harness"
  ]
}

variable "external_secrets_namespace" {
  type = string
  default = "external-secrets"
}

variable "external_secrets_kubernetes_sa_name" {
  type = string
  default = "external-secrets"
}

variable "cert_manager_namespace" {
  type = string
  default = "cert-manager"
}

variable "argocd_namespace" {
  type = string
  default = "argocd"
}

variable "environment_role" {
  type = string
  default = "master"
  description = "Tells argo what branch to pull from. Used for testing new features. Ex Develop."
}
