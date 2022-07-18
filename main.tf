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
  #########################################
  # VPC
  #########################################
  cidr = "10.100.0.0/16"
  # availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  public_subnets     = ["10.100.0.0/24", "10.100.1.0/24", "10.100.2.0/24"]
  private_subnets    = ["10.100.3.0/24", "10.100.4.0/24", "10.100.5.0/24"]

  #########################################
  # Application
  #########################################
  account      = data.aws_caller_identity.current.account_id
  region       = data.aws_region.current.name
  app_name     = "${var.env}-ecs-${var.team}"
  env          = var.env
  team         = var.team
  app_services = ["webapp", "customer", "transaction"]

  #DNS for internal R53 private zone
  internal_zone_name = "forrester.internal"

  #########################################
  #ALB
  #########################################
  #Internal ALB config
  internal_alb_config = {
    name = "Internal-Alb"
    listeners = {
      "HTTP" = {
        listener_port     = 80
        listener_protocol = "HTTP"

      }
    }

    ingress_rules = [
      {
        from_port   = 80
        to_port     = 3000
        protocol    = "tcp"
        cidr_blocks = ["10.100.0.0/16"]
      }
    ]

    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.100.0.0/16"]
      }
    ]
  }

  #Public ALB config
  public_alb_config = {
    name = "Public-Alb"
    listeners = {
      "HTTP" = {
        listener_port     = 80
        listener_protocol = "HTTP"

      }
    }

    ingress_rules = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]

    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
  #########################################
  # ECS
  #########################################
  microservice_config = {
    "WebApp" = {
      name           = "WebApp"
      is_public      = true
      container_port = 80
      host_port      = 80
      image          = "sconnolly1886/frontend:v1"
      cpu            = 256
      memory         = 512
      desired_count  = 1
      alb_target_group = {
        port              = 80
        protocol          = "HTTP"
        path_pattern      = ["/*"]
        health_check_path = "/health"
        priority          = 1
      }
      auto_scaling = {
        max_capacity = 1
        min_capacity = 1
        cpu = {
          target_value = 75
        }
        memory = {
          target_value = 75
        }
      }
    },
    "Customer" = {
      name           = "Customer"
      is_public      = false
      container_port = 3000
      host_port      = 3000
      image          = "sconnolly1886/custserv:v3"
      cpu            = 256
      memory         = 512
      desired_count  = 1
      alb_target_group = {
        port              = 3000
        protocol          = "HTTP"
        path_pattern      = ["/customer*"]
        health_check_path = "/health"
        priority          = 1
      }
      auto_scaling = {
        max_capacity = 2
        min_capacity = 1
        cpu = {
          target_value = 75
        }
        memory = {
          target_value = 75
        }
      }
    },
    "Transaction" = {
      name           = "Transaction"
      is_public      = false
      container_port = 3000
      host_port      = 3000
      image          = "sconnolly1886/transaction:v2"
      cpu            = 256
      memory         = 512
      desired_count  = 1
      alb_target_group = {
        port              = 3000
        protocol          = "HTTP"
        path_pattern      = ["/transaction*"]
        health_check_path = "/health"
        priority          = 1
      }
      auto_scaling = {
        max_capacity = 2
        min_capacity = 1
        cpu = {
          target_value = 75
        }
        memory = {
          target_value = 75
        }
      }
    }
  }
}

#########################################
# GLOBAL
#########################################
module "global" {
  source = "./modules/global"
  env    = var.env
}
