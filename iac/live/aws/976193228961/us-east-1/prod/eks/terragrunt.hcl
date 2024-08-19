include "root" {
  # Pull the root terragrunt.hcl
  path = find_in_parent_folders()
}

include "shared" {
  # Pull the shared eks configuration.
  path = "${get_repo_root()}/iac/live/_shared/eks.hcl"
  # Expose the locals from the shared file.
  expose = true
}

terraform {
  # The TF module version to use.
  # This allows us to pin the TF module and independently upgrade on a per-environment basis.
  source = "${include.shared.locals.source_url}=20.23.0"
}