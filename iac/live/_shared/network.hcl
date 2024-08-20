locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env_name

  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region_name = local.region_vars.locals.region_name

  team_vars = read_terragrunt_config(find_in_parent_folders("teams.hcl"))
  team      = local.team_vars.locals.team

  registry_vars = read_terragrunt_config(find_in_parent_folders("registries.hcl"))
  tfr_src       = local.registry_vars.locals.tfr_src
  tfr_tag_query = local.registry_vars.locals.tfr_tag_query

  source_url = "${local.tfr_src}/terraform-aws-modules/vpc/aws${local.tfr_tag_query}"

  network_name = "vpc-dmgblockchain-${local.env_name}"
  vpc_cidr     = "10.0.0.0/16"
  azs          = ["${local.region_name}a", "${local.region_name}b", "${local.region_name}c"]
}

inputs = {
  name = local.network_name
  cidr = local.vpc_cidr
  azs  = local.azs

  # See https://developer.hashicorp.com/terraform/language/functions/cidrsubnet for more info.
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_ipv6          = false
  enable_dns_hostnames = true
  enable_nat_gateway   = true # Managed EKS nodes in private subnets must have a NAT Gateway for connectivity.
  single_nat_gateway   = true # In production, use multiple NAT gateways for redundancy.

  tags = {
    Environment = local.env_name
    Region      = local.region_name
    Team        = local.team.devops
    Terraform   = true
    Terragrunt  = true
  }
}