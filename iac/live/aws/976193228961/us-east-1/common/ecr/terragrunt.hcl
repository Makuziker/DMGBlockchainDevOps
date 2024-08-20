include "root" {
  path = find_in_parent_folders()
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env_name

  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region_name = local.region_vars.locals.region_name

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id   = local.account_vars.locals.account_id

  registry_vars = read_terragrunt_config(find_in_parent_folders("registries.hcl"))
  tfr_src       = local.registry_vars.locals.tfr_src
  tfr_tag_query = local.registry_vars.locals.tfr_tag_query

  team_vars = read_terragrunt_config(find_in_parent_folders("teams.hcl"))
  team      = local.team_vars.locals.team

  source_url = "${local.tfr_src}/cloudposse/ecr/aws${local.tfr_tag_query}"
}

terraform {
  source = "${local.source_url}=0.42.0"
}

inputs = {
  namespace           = local.team.devops
  max_image_count     = 10
  scan_images_on_push = true

  image_names = [
    "dmgblockchaindevops-web",
    "dmgblockchaindevops-api"
  ]

  tags = {
    Environment = local.env_name
    Team        = local.team.devops
    Region      = local.region_name
    Terraform   = true
    Terragrunt  = true
  }
}