data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

#########################################
# REGIONAL
#########################################
module "regional" {
  source = "./modules/regional"
  account      = var.account
  region       = data.aws_region.current.name
  env          = var.env
  team         = var.team
}

#########################################
# GLOBAL
#########################################
module "global" {
  source = "./modules/global"
  env    = var.env
}
