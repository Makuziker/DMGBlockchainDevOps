include "root" {
  path = find_in_parent_folders()
}

include "shared" {
  path   = "${get_repo_root()}/iac/live/_shared/network.hcl"
  expose = true
}

terraform {
  source = "${include.shared.locals.source_url}=5.13.0"
}