#----------
# Variables
#----------

variable "project_name" {
  description = "project name is used as resource tag"
  type        = string
}

variable "region" {
  description = "AWS region to deploy to"
  type        = string
}


#-------------------
# Locals
#-------------------
locals {
  region  = data.aws_region.current.name
  account = data.aws_caller_identity.current.account_id
}
