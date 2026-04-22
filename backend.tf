############################################
# backend.tf
#
# PURPOSE:
# - Store terraform.tfstate in S3
# - Enable state locking via S3 lock file
# - Share state across GitHub Actions & VM
############################################

terraform {
  backend "s3" {
    bucket = "abc-startup-terraform-state"
    key    = "abc-startup/terraform.tfstate"
    region = "ap-south-1"

    # Encrypt state at rest
    encrypt = true

    # Modern Terraform locking (>= 1.5)
    use_lockfile = true
  }
}
