#!/bin/bash

# MacOS installation: Terraform & Terragrunt
brew tap hashicorp/tap
brew install tfenv
# Locks the TF version to what is specified in .terraform-version file.
tfenv use
brew install terragrunt

terraform --version
terragrunt --version
