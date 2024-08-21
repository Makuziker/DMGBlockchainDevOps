locals {
  registry_vars = read_terragrunt_config(find_in_parent_folders("registries.hcl"))
  tfr_src       = local.registry_vars.locals.tfr_src
  tfr_tag_query = local.registry_vars.locals.tfr_tag_query

  source_url = "${local.tfr_src}/aigisuk/argocd/kubernetes${local.tfr_tag_query}"
}

# While possible, I do not recommend using `kubectl` in a pipeline like circleci to apply k8s manifests to the EKS cluster.
# With this TF module (which is a wrapper for a Helm chart), we can deploy ArgoCD to the EKS cluster via IaC.
# Once setup, ArgoCD can poll the git repo for manifest changes and sync them to the cluster.
# This is a more reliable and scalable approach to managing k8s manifests.

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
  provider "helm" {
    kubernetes {
      config_path = "~/.kube/config"
    }
  }
  EOF
}

inputs = {}