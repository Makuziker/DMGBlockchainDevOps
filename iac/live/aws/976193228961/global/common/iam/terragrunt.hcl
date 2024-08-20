include "root" {
  path = find_in_parent_folders()
}

include "shared" {
  path   = "${get_repo_root()}/iac/live/_shared/iam.hcl"
  expose = true
}

terraform {
  source = "${include.shared.locals.source_url}=v7.4.1"
}

locals {
  policies_dir = include.shared.locals.policies_dir
  account_id   = include.shared.locals.account_id
  region_name  = include.shared.locals.region_name
  team         = include.shared.locals.team
}

inputs = {
  users = [
    {
      name        = "circleci"
      path        = "/${local.team.mining}/ci/"
      groups      = ["ci"]
      access_keys = []
    }
  ]

  groups = [
    {
      name = "ci"
      path = "/${local.team.mining}/ci/"
      policies = [
        "ECRWebReadWritePolicy",
        "ECRApiReadWritePolicy"
      ]
    }
  ]

  policies = [
    {
      name = "ECRWebReadWritePolicy"
      path = "/${local.team.mining}/web/"
      desc = "Allows read/write access to the web container registry"
      file = "${local.policies_dir}/ecr/read-write.json.tmpl"
      vars = {
        account_id      = local.account_id
        region_name     = "us-east-1"
        repository_name = "dmgblockchaindevops-web"
      }
    },
    {
      name = "ECRApiReadWritePolicy"
      path = "/${local.team.mining}/api/"
      desc = "Allows read/write access to the api container registry"
      file = "${local.policies_dir}/ecr/read-write.json.tmpl"
      vars = {
        account_id      = local.account_id
        region_name     = "us-east-1"
        repository_name = "dmgblockchaindevops-api"
      }
    }
  ]
}