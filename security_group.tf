resource "aws_security_group" "dre_eks_loadbalancer_security_group_restricted_0" {
  name        = "dre-loadbalancer-security-group-restricted-0"
  description = "Security Group used for Loadbalancer limit to Zscaler and VPN"
  vpc_id      = module.dre_crossplane_primary_vpc.vpc_id

  ingress {
    description      = "HTTP 0"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.inbound_allowable_restricted_ip_ranges_0
    ipv6_cidr_blocks = var.inbound_allowable_restricted_ip_ranges_ipv6
  }

  ingress {
    description      = "HTTPS 0"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.inbound_allowable_restricted_ip_ranges_0
    ipv6_cidr_blocks = var.inbound_allowable_restricted_ip_ranges_ipv6
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    var.tags,
    {
      "Name" = "dre-loadbalancer-security-group-restricted-0"
    },
  )
}

resource "aws_security_group" "dre_eks_loadbalancer_security_group_restricted_1" {
  name        = "dre-loadbalancer-security-group-restricted-1"
  description = "Security Group used for Loadbalancer limit to Zscaler and VPN"
  vpc_id      = module.dre_crossplane_primary_vpc.vpc_id

  ingress {
    description = "HTTP 1"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.inbound_allowable_restricted_ip_ranges_1
  }

  ingress {
    description = "HTTPS 1"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.inbound_allowable_restricted_ip_ranges_1
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    var.tags,
    {
      "Name" = "dre-loadbalancer-security-group-restricted-1"
    }
  )
}

resource "aws_security_group" "dre_eks_loadbalancer_security_group_restricted_2" {
  name        = "dre-loadbalancer-security-group-restricted-2"
  description = "Security Group used for Loadbalancer limit to Zscaler and VPN"
  vpc_id      = module.dre_crossplane_primary_vpc.vpc_id

  ingress {
    description = "HTTP 1"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.inbound_allowable_restricted_ip_ranges_2
  }

  ingress {
    description = "HTTPS 1"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.inbound_allowable_restricted_ip_ranges_2
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    var.tags,
    {
      "Name" = "dre-loadbalancer-security-group-restricted-2"
    }
  )
}

