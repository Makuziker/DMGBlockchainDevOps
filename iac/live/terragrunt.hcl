# The root terragrunt.hcl is pulled by all children for shared configuration.

# TF backend resources are created outside of Terraform.
# While possible, I do not recommend letting infrastructure code manage itself.
#
# The tfstate path in S3 automatically matches with the paths in the Terragrunt directory hierarchy.
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
  terraform {
    backend "s3" {
      bucket         = "bklombies-tf-remote-state"
      key            = "${path_relative_to_include()}/terraform.tfstate"
      region         = "us-east-1"
      dynamodb_table = "terraform-state-locks"
      encrypt        = true
    }
  }
  EOF
}

# Todo: configure a role for accessing remote state, and a role for TF provisioning.