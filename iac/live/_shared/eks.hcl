# Shared files are pulled and read from the context of the child terragrunt.hcl file.

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env_name

  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region_name = local.region_vars.locals.region_name

  registry_vars = read_terragrunt_config(find_in_parent_folders("registries.hcl"))
  tfr_src       = local.registry_vars.locals.tfr_src
  tfr_tag_query = local.registry_vars.locals.tfr_tag_query

  source_url = "${local.tfr_src}/terraform-aws-modules/eks/aws${local.tfr_tag_query}"
}