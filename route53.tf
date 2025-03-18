# Create root Route53 hosted zone.
resource "aws_route53_zone" "iac_percipio_com" {
  name = var.iac_percipio_domain

  tags = local.tags
}

# Create Route53 zone for Controlplane subdomain.
resource "aws_route53_zone" "controlplane_iac_percipio_com" {
  name = "controlplane.${var.iac_percipio_domain}"

  tags = local.tags
}

# Create NS records in the root hosted zone for the Controlplane subdomain.
resource "aws_route53_record" "controlplane_ns" {
  zone_id = aws_route53_zone.iac_percipio_com.zone_id
  name    = "controlplane.${var.iac_percipio_domain}"
  type    = "NS"
  ttl     = 300

  records = [
    aws_route53_zone.controlplane_iac_percipio_com.name_servers[0],
    aws_route53_zone.controlplane_iac_percipio_com.name_servers[1],
    aws_route53_zone.controlplane_iac_percipio_com.name_servers[2],
    aws_route53_zone.controlplane_iac_percipio_com.name_servers[3]
  ]
}