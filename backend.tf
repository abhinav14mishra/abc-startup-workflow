#############################################
# backend.tf
#
# PURPOSE:
# - Remote S3 backend for Terraform state
# - Prevents concurrent state corruption
#############################################

terraform {
  backend "s3" {
    bucket         = "abc-startup-terraform-state"
    key            = "abc-startup/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true

    # S3-native locking (Terraform >= 1.5)
    use_lockfile   = true
  }
}