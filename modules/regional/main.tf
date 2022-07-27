provider "aws" {
  region = local.primary.region
  assume_role {
  role_arn     = var.account
  session_name = "INFRA_BUILD"
  }
}

provider "aws" {
  alias  = "secondary"
  region = local.secondary.region
  assume_role {
  role_arn     = var.account
  session_name = "INFRA_BUILD"
  }
}

locals {
  name = "forr-${var.team}"
  primary = {
    region      = var.region
  }
  secondary = {
    region      = lookup(var.region_mapping, var.region)
  }
  tags = {
    Owner       = var.team
    Environment = var.env
  }
}

data "aws_caller_identity" "current" {}

################################################################################
# Supporting Resources
################################################################################

module "primary_vpc" {
  source  = "./modules/vpc"

  name = local.name
  cidr = "10.16.0.0/16"

  azs                 = ["${local.primary.region}a", "${local.primary.region}b", "${local.primary.region}c"]
  private_subnets     = ["10.16.1.0/24", "10.16.2.0/24", "10.16.3.0/24"]
  public_subnets      = ["10.16.11.0/24", "10.16.12.0/24", "10.16.13.0/24"]
  database_subnets    = ["10.16.21.0/24", "10.16.22.0/24", "10.16.23.0/24"]
  elasticache_subnets = ["10.16.31.0/24", "10.16.32.0/24", "10.16.33.0/24"]
  # enable_nat_gateway = false
  # single_nat_gateway = false
  # one_nat_gateway_per_az = false
  # enable_vpn_gateway = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = local.tags
}

module "secondary_vpc" {
  source  = "./modules/vpc"

  providers = { aws = aws.secondary }

  name = local.name
  cidr = "10.16.0.0/16"

  azs                 = ["${local.secondary.region}a", "${local.secondary.region}b", "${local.secondary.region}c"]
  private_subnets     = ["10.16.1.0/24", "10.16.2.0/24", "10.16.3.0/24"]
  public_subnets      = ["10.16.11.0/24", "10.16.12.0/24", "10.16.13.0/24"]
  database_subnets    = ["10.16.21.0/24", "10.16.22.0/24", "10.16.23.0/24"]
  elasticache_subnets = ["10.16.31.0/24", "10.16.32.0/24", "10.16.33.0/24"]
  # enable_nat_gateway = false
  # single_nat_gateway = false
  # one_nat_gateway_per_az = false
  # enable_vpn_gateway = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = local.tags
}

data "aws_iam_policy_document" "rds" {
  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        data.aws_caller_identity.current.arn,
      ]
    }
  }

  statement {
    sid = "Allow use of the key"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]

    principals {
      type = "Service"
      identifiers = [
        "monitoring.rds.amazonaws.com",
        "rds.amazonaws.com",
      ]
    }
  }
}

resource "aws_kms_key" "primary" {
  policy = data.aws_iam_policy_document.rds.json
  tags   = local.tags
}

resource "aws_kms_key" "secondary" {
  provider = aws.secondary

  policy = data.aws_iam_policy_document.rds.json
  tags   = local.tags
}

################################################################################
# RDS Aurora Module
################################################################################

resource "aws_rds_global_cluster" "this" {
  global_cluster_identifier = local.name
  engine                    = "aurora-postgresql"
  engine_version            = "13.6"
  database_name             = var.database_name
  storage_encrypted         = true
}

module "aurora_primary" {
  source = "./modules/rds-aurora"

  name                      = local.name
  database_name             = aws_rds_global_cluster.this.database_name
  engine                    = aws_rds_global_cluster.this.engine
  engine_version            = aws_rds_global_cluster.this.engine_version
  global_cluster_identifier = aws_rds_global_cluster.this.id
  iam_database_authentication_enabled = true
  # master_username           = var.master_username   # Set to DBAdmin
  # master_password           = "RANDOMLYGENERATED"
  monitoring_interval       = 60
  iam_role_name             = "${local.name}-monitor"
  autoscaling_enabled       = true
  autoscaling_min_capacity  = 1
  autoscaling_max_capacity  = 3
  instance_class            = "db.r5.large"
  instances                 = { for i in range(2) : i => {} }
  kms_key_id                = aws_kms_key.primary.arn

  vpc_id                 = module.primary_vpc.vpc_id
  db_subnet_group_name   = module.primary_vpc.database_subnet_group_name
  create_db_subnet_group = false
  create_security_group  = true
  allowed_cidr_blocks    = module.primary_vpc.private_subnets_cidr_blocks

  skip_final_snapshot = true

  tags = local.tags
}

module "aurora_secondary" {
  source = "./modules/rds-aurora"

  providers = { aws = aws.secondary }

  is_primary_cluster = false

  name                      = local.name
  engine                    = aws_rds_global_cluster.this.engine
  engine_version            = aws_rds_global_cluster.this.engine_version
  global_cluster_identifier = aws_rds_global_cluster.this.id
  source_region             = local.primary.region
  iam_database_authentication_enabled = true
  monitoring_interval       = 60
  autoscaling_enabled       = true
  autoscaling_min_capacity  = 1
  autoscaling_max_capacity  = 2
  instance_class            = "db.r5.large"
  instances                 = { for i in range(1) : i => {} }
  kms_key_id                = aws_kms_key.secondary.arn

  vpc_id                 = module.secondary_vpc.vpc_id
  db_subnet_group_name   = module.secondary_vpc.database_subnet_group_name
  create_db_subnet_group = false
  create_security_group  = true
  allowed_cidr_blocks    = module.secondary_vpc.private_subnets_cidr_blocks

  skip_final_snapshot = true

  depends_on = [
    module.aurora_primary
  ]

  tags = local.tags
}


# ################################################################################
# # VPC Endpoints Module
# ################################################################################

# module "vpc_endpoints" {
#   source = "../../modules/vpc-endpoints"

#   vpc_id             = module.vpc.vpc_id
#   security_group_ids = [data.aws_security_group.default.id]

#   endpoints = {
#     s3 = {
#       service = "s3"
#       tags    = { Name = "s3-vpc-endpoint" }
#     },
#     dynamodb = {
#       service         = "dynamodb"
#       service_type    = "Gateway"
#       route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
#       policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
#       tags            = { Name = "dynamodb-vpc-endpoint" }
#     },
#     ssm = {
#       service             = "ssm"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#       security_group_ids  = [aws_security_group.vpc_tls.id]
#     },
#     ssmmessages = {
#       service             = "ssmmessages"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     lambda = {
#       service             = "lambda"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     ecs = {
#       service             = "ecs"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     ecs_telemetry = {
#       create              = false
#       service             = "ecs-telemetry"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     ec2 = {
#       service             = "ec2"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#       security_group_ids  = [aws_security_group.vpc_tls.id]
#     },
#     ec2messages = {
#       service             = "ec2messages"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     ecr_api = {
#       service             = "ecr.api"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#       policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
#     },
#     ecr_dkr = {
#       service             = "ecr.dkr"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#       policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
#     },
#     kms = {
#       service             = "kms"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#       security_group_ids  = [aws_security_group.vpc_tls.id]
#     },
#     codedeploy = {
#       service             = "codedeploy"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     codedeploy_commands_secure = {
#       service             = "codedeploy-commands-secure"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#   }

#   tags = merge(local.tags, {
#     Project  = "Secret"
#     Endpoint = "true"
#   })
# }
