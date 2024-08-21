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

  source_url = "${local.tfr_src}/aigisuk/argocd/kubernetes${local.tfr_tag_query}"
}

# While possible, I do not recommend using `kubectl` in a pipeline like circleci to apply k8s manifests to the EKS cluster.
# With this TF module (which is a wrapper for a Helm chart), we can deploy ArgoCD to the EKS cluster via IaC.
# Once setup, ArgoCD can poll the git repo for manifest changes and sync them to the cluster.
# This is a more reliable and scalable approach to managing k8s manifests.

# NOT IMPLEMENTED YET