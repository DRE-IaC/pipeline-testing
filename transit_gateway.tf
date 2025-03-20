##
# transit_gateway.tf contains all related resources required to connect the controlplane to netsec. 
##

// Default group created by public module so creating another one for required rules. 
resource "aws_security_group" "controlplane_netsec_access" {
  name        = "use2-iac-controlplane-node-netsec"
  description = "Security Group used by nodes to connect to netsec"
  vpc_id      = module.dre_crossplane_primary_vpc.vpc_id

  ingress {
    description      = "Zscaler 1"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["10.80.0.30/32"]
  }

  ingress {
    description      = "Zscaler 2"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["10.80.10.30/32"]
  }

  ingress {
    description      = "Cisco Secure"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["10.249.0.0/16"]
  }

 # required for karpenter to associate nodes with the group. 
  tags = {
    Name = "${var.cluster_name}-node"
  }
}

resource "aws_route" "controlplane-1" {
  route_table_id            = module.dre_crossplane_primary_vpc.private_route_table_ids[0]
  destination_cidr_block = "10.249.0.0/16"
  gateway_id             = "tgw-05c73be4a2d78627a"
}

resource "aws_route" "controlplane-2" {
  route_table_id            = module.dre_crossplane_primary_vpc.private_route_table_ids[0]
  destination_cidr_block = "10.80.0.0/19"
  gateway_id             = "tgw-05c73be4a2d78627a"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "controlplane" {
  subnet_ids         = module.dre_crossplane_primary_vpc.private_subnets
  transit_gateway_id = "tgw-0c404f6ebcdb26bc2"
  vpc_id             = module.dre_crossplane_primary_vpc.vpc_id

  tags = var.tags
}

resource "aws_ec2_transit_gateway_vpc_attachment" "controlplane2" {
  subnet_ids         = module.dre_crossplane_primary_vpc.private_subnets
  transit_gateway_id = "tgw-05c73be4a2d78627a"
  vpc_id             = module.dre_crossplane_primary_vpc.vpc_id

  tags = var.tags
}