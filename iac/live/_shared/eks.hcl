# Shared files are pulled and read from the context of the child terragrunt.hcl file.

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

  # This file is gitignored for privacy.
  secret_vars = read_terragrunt_config(find_in_parent_folders("secrets.hcl"))
  admin_cidrs = local.secret_vars.locals.admin_cidrs

  source_url = "${local.tfr_src}/terraform-aws-modules/eks/aws${local.tfr_tag_query}"
}

# EKS module depends on the network module. Here I reference the network that exists in the same region.
dependency "network" {
  config_path = "${get_terragrunt_dir()}/../../common/network"
}

# Managed worker nodes in private subnets need a NAT Gateway to access ECR?
inputs = {
  cluster_name    = "dmgblockchain-${local.env_name}"
  cluster_version = "1.30"

  cluster_endpoint_public_access           = true
  cluster_endpoint_public_access_cidrs     = local.admin_cidrs # Hides my IP address from the public github repo.
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns                = {}
    eks_pod_identity_agent = {}
    kube_proxy             = {}
    vpc_cni                = {}
  }

  vpc_id     = dependency.network.outputs.vpc_id
  subnet_ids = slice(dependency.network.outputs.private_subnets, 0, 3)

  eks_managed_node_groups = {
    standard_worker = {
      instance_types = ["t3.small"]
      min_size       = 2
      max_size       = 3
      desired_size   = 2
    }
  }

  tags = {
    Environment = local.env_name
    Region      = local.region_name
    Team        = local.team.devops
    Terraform   = true
    Terragrunt  = true
  }
}