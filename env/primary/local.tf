locals {
  account_id = data.aws_caller_identity.current.account_id
  prefix     = "use2-controlplane-"
  zone       = "primary-${local.account_id}"

  params_prefix = "/${replace(local.prefix, "-", "/")}"

  tags = merge(var.tags, {
    environment = var.environment
    region      = var.region
  })
}
