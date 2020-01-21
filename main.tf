terraform {
    # The configuration for this backend will be filled in by Terragrunt
    backend "s3" {}
}

provider "aws" {
  region = "${var.region}"
}

locals {
  tags = {
    Environment = "${var.environment}"
    Terraform = "True"
  }
}
