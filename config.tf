#--- 0_tfstate/config.tf ---

terraform {
  required_version = "~> 0.13"
  required_providers {
    aws = ">= 3.2.0"
  }
}

provider "aws" {
  region = var.region
  profile = "default"
}
