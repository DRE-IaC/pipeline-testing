# New VPC with CloudOps CIDR reservations for peering.

module "dre_crossplane_primary_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.13"

  name = local.name
  cidr = var.base_cidr_use2_controlplane_primary

  azs = [
    for k, v in var.azs_public :format("%s%s", var.region, k)
  ]
  public_subnets = [
    for k, v in var.azs_public :
    cidrsubnet(var.base_cidr_use2_controlplane_primary, 4, v)
  ]
  private_subnets = [
    for k, v in var.azs_private :
    cidrsubnet(var.base_cidr_use2_controlplane_primary, 4, v)
  ]


  create_egress_only_igw        = true
  enable_nat_gateway            = true
  single_nat_gateway            = true
  enable_dns_hostnames          = true
  enable_dns_support            = true


  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    "Name"                   = "dre-ctrlpln-0-public"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "Name"                            = "dre-ctrlpln-0-private"
  }

  public_route_table_tags = merge(local.tags, {
    "Name" : "dre-vpc-0-public"
  })

  private_route_table_tags = merge(local.tags, {
    "Name" : "dre-vpc-0-private"
  })

  default_route_table_tags = merge(local.tags, {
    "Name" : "dre-vpc-0-default-route"
  })

  tags = local.tags
}

locals {
  name = "dre-controlplane"
}
