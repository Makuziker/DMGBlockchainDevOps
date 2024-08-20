locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env_name

  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region_name = local.region_vars.locals.region_name

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id   = local.account_vars.locals.account_id

  team_vars = read_terragrunt_config(find_in_parent_folders("teams.hcl"))
  team = local.team_vars.locals.team

  registry_vars    = read_terragrunt_config(find_in_parent_folders("registries.hcl"))
  github_src       = local.registry_vars.locals.github_src
  github_tag_query = local.registry_vars.locals.github_tag_query

  # Note: This is a forked repo based on cytopia/terraform-aws-iam, which became incompatible since TF v0.12.
  #       For a module so important for security, I recommend maintaining our own fork or clone.
  source_url = "${local.github_src}/Flaconi/terraform-aws-iam-roles${local.github_tag_query}"

  policies_dir = "${get_repo_root()}/iac/live/files/iam/policies"
}