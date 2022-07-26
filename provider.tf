terraform {
  backend "s3" {
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.74"
      # configuration_aliases = [aws.use2]
    }
  }
  required_version = "> 0.14"
}

provider "aws" {
  region = var.region
  assume_role {
    role_arn     = var.account
    session_name = "INFRA_BUILD"
  }
}

provider "aws" {
  region = "${lookup(var.region_mapping, var.region)}"
  alias = "secondary"
  assume_role {
    role_arn     = var.account
    session_name = "INFRA_BUILD"
  }
}