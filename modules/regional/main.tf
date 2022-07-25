data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "s3" {
  source                  = "./modules/s3"
  environment_name        = "sandbox"
}

module "vpc" {
  source                  = "./modules/vpc"
  providers               = {
    aws = "aws"
  }
  environment_name        = "sandbox"
  param_post_fix          = ""
  log_bucket              = module.s3.s3_arn
  vpc_cidr                = "10.12.0.0/16"
  public_subnet00_cidr    = "10.12.0.0/24"
  public_subnet01_cidr    = "10.12.1.0/24"
  public_subnet02_cidr    = "N/A"
  public_subnet03_cidr    = "N/A"
  public_subnet04_cidr    = "N/A"
  private_subnet00_cidr   = "10.12.10.0/24"
  private_subnet01_cidr   = "10.12.11.0/24"
  private_subnet02_cidr   = "N/A"
  private_subnet03_cidr   = "N/A"
  private_subnet04_cidr   = "N/A"
  protected_subnet00_cidr = "10.12.20.0/24"
  protected_subnet01_cidr = "10.12.21.0/24"
  protected_subnet02_cidr = "N/A"
  protected_subnet03_cidr = "N/A"
  protected_subnet04_cidr = "N/A"
  services_subnet00_cidr  = "10.12.30.0/24"
  services_subnet01_cidr  = "10.12.31.0/24"
  services_subnet02_cidr  = "N/A"
  services_subnet03_cidr  = "N/A"
  services_subnet04_cidr  = "N/A"
}

# module "vpc2" {
#   source                  = "./modules/vpc"
#   providers               = {
#     aws = "aws.use2"
#   }
#   environment_name        = "sandbox"
#   log_bucket              = module.s3.s3_arn
#   param_post_fix          = ""
#   vpc_cidr                = "10.12.0.0/16"
#   public_subnet00_cidr    = "10.12.0.0/24"
#   public_subnet01_cidr    = "10.12.1.0/24"
#   public_subnet02_cidr    = "N/A"
#   public_subnet03_cidr    = "N/A"
#   public_subnet04_cidr    = "N/A"
#   private_subnet00_cidr   = "10.12.10.0/24"
#   private_subnet01_cidr   = "10.12.11.0/24"
#   private_subnet02_cidr   = "N/A"
#   private_subnet03_cidr   = "N/A"
#   private_subnet04_cidr   = "N/A"
#   protected_subnet00_cidr = "10.12.20.0/24"
#   protected_subnet01_cidr = "10.12.21.0/24"
#   protected_subnet02_cidr = "N/A"
#   protected_subnet03_cidr = "N/A"
#   protected_subnet04_cidr = "N/A"
#   services_subnet00_cidr  = "10.12.30.0/24"
#   services_subnet01_cidr  = "10.12.31.0/24"
#   services_subnet02_cidr  = "N/A"
#   services_subnet03_cidr  = "N/A"
#   services_subnet04_cidr  = "N/A"
# }
