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

inputs = {
  cluster_name    = "dmgblockchain-${local.env_name}"
  cluster_version = "1.30"
  # "Platform Version": "eks.6"

  cluster_endpoint_public_access           = true
  cluster_endpoint_public_access_cidrs     = local.admin_cidrs # Hides my IP address from the public github repo.
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns = {
      addon_version = "v1.11.1-eksbuild.8"
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    kube-proxy = {
      addon_version = "v1.30.0-eksbuild.3"
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # This policy is required for the EBS CSI driver to work.
  iam_role_additional_policies = {
    AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  vpc_id     = dependency.network.outputs.vpc_id
  subnet_ids = slice(dependency.network.outputs.private_subnets, 0, 3)

  # AWS recommends creating the cluster BEFORE defining the managed node groups.
  # Otherwise the managed node groups tend to get stuck.
  eks_managed_node_groups = {
    "eks-standard-${local.env_name}" = {
      instance_types = ["t3.small"]
      min_size       = 2
      max_size       = 3
      desired_size   = 2
    }
  }

  cluster_upgrade_policy = {
    support_type = "STANDARD"
  }

  tags = {
    Environment = local.env_name
    Region      = local.region_name
    Team        = local.team.devops
    Terraform   = true
    Terragrunt  = true
  }
}