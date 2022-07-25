locals {
  common_tags = {
    Purpose   = "caylent-pipeline-deployment"
    CreatedBy = "Caylent"
    ManagedBy = "infrastructure-pipeline"
  }
}

##########################################
# Data Sources
##########################################
data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


##########################################
# VPC
##########################################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-vpc"
    },
  )
}

# ##########################################
# # SSM Parameter - VPC ID
# ##########################################
# resource "aws_ssm_parameter" "vpc_id" {
#   name        = "/caylent/vpc${var.param_post_fix}/id"
#   description = "VPC ID"
#   type        = "String"
#   value       = aws_vpc.vpc.id
# }

# ##########################################
# # SSM Parameter - VPC CIDR
# ##########################################
# resource "aws_ssm_parameter" "vpc_cidr" {
#   name  = "/caylent/vpc${var.param_post_fix}/cidr"
#   type  = "String"
#   value = aws_vpc.vpc.cidr_block
# }

##########################################
# IGW
##########################################
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-igw"
    },
  )
}

##########################################
# NAT Gateway
##########################################
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw_eip.allocation_id
  subnet_id     = aws_subnet.public_subnet_0.id
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-nat"
    },
  )

  depends_on = [aws_internet_gateway.internet_gateway, aws_eip.natgw_eip]
}

##########################################
# Elastic IP - for NATGW
##########################################
resource "aws_eip" "natgw_eip" {
  vpc = true
}

##########################################
# Public Route Table
##########################################
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-public-rt"
    },
  )
}

# ##########################################
# # SSM Parameter - Public Route Table Id
# ##########################################
# resource "aws_ssm_parameter" "public_route_table_id" {
#   name        = "/caylent/vpc${var.param_post_fix}/public/routetable/id"
#   description = "Public Route Table ID"
#   type        = "String"
#   value       = aws_route_table.public_route_table.id
# }

##########################################
# Private Route Table
##########################################
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-private-rt"
    },
  )
}

# ##########################################
# # SSM Parameter - Private Route Table Id
# ##########################################
# resource "aws_ssm_parameter" "private_route_table_id" {
#   name        = "/caylent/vpc${var.param_post_fix}/private/routetable/id"
#   description = "Private Route Table ID"
#   type        = "String"
#   value       = aws_route_table.private_route_table.id
# }


##########################################
# Protected Route Table
##########################################
resource "aws_route_table" "protected_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }


  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-protected-rt"
    },
  )
}

# ##########################################
# # SSM Parameter - Protected Route Table Id
# ##########################################
# resource "aws_ssm_parameter" "protected_route_table_id" {
#   name        = "/caylent/vpc${var.param_post_fix}/protected/routetable/id"
#   description = "Protected Route Table ID"
#   type        = "String"
#   value       = aws_route_table.protected_route_table.id
# }

##########################################
# Services Route Table
##########################################
resource "aws_route_table" "services_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }


  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-services-rt"
    },
  )
}

# ##########################################
# # SSM Parameter - Services Route Table Id
# ##########################################
# resource "aws_ssm_parameter" "services_route_table_id" {
#   name        = "/caylent/vpc${var.param_post_fix}/services/routetable/id"
#   description = "Services Route Table ID"
#   type        = "String"
#   value       = aws_route_table.services_route_table.id
# }

# ********************************************************************
# ************************** VPC Flow Logs ***************************
# ********************************************************************



##################################
# VPC Flow Log
##################################
resource "aws_flow_log" "vpc_flow_log" {
  log_destination_type = "s3"
  log_destination      = var.log_bucket
  vpc_id               = aws_vpc.vpc.id
  traffic_type         = "ALL"

}

# *********************************************************
# ***** Subnets *******************************************
# *********************************************************


##########################################
# Public Subnets
##########################################

##########################################
# Public Subnet 0
##########################################
resource "aws_subnet" "public_subnet_0" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet00_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-public-subnet-00"
    },
  )
}
# ##########################################
# # SSM Parameter - Public Subnet00 Id
# ##########################################
# resource "aws_ssm_parameter" "public_subnet00_id_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/public/subnet/00/id"
#   description = "Public Subnet 00 ID"
#   type        = "String"
#   value       = aws_subnet.public_subnet_0.id
# }

# ##########################################
# # SSM Parameter - Public Subnet00 CIDR
# ##########################################
# resource "aws_ssm_parameter" "public_subnet00_cidr_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/public/subnet/00/cidr"
#   description = "Public Subnet 00 CIDR"
#   type        = "String"
#   value       = var.public_subnet00_cidr
# }

##########################################
# Public Subnet 01
##########################################
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet01_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-public-subnet-01"
    },
  )
}
# ##########################################
# # SSM Parameter - Public Subnet01 Id
# ##########################################
# resource "aws_ssm_parameter" "public_subnet01_id_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/public/subnet/01/id"
#   description = "Public Subnet 01 ID"
#   type        = "String"
#   value       = aws_subnet.public_subnet_1.id
# }

# ##########################################
# # SSM Parameter - Public Subnet01 CIDR
# ##########################################
# resource "aws_ssm_parameter" "public_subnet01_cidr_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/public/subnet/01/cidr"
#   description = "Public Subnet 01 CIDR"
#   type        = "String"
#   value       = var.public_subnet01_cidr
# }

##########################################
# Public Subnet 02
##########################################
resource "aws_subnet" "public_subnet_2" {
  count      = var.public_subnet02_cidr == "N/A" ? 0 : 1
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet02_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-public-subnet-02"
    },
  )
}
# ##########################################
# # SSM Parameter - Public Subnet02 Id
# ##########################################
# resource "aws_ssm_parameter" "public_subnet02_id_output" {
#   count       = var.public_subnet02_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/public/subnet/02/id"
#   description = "Public Subnet 02 ID"
#   type        = "String"
#   value       = aws_subnet.public_subnet_2.*.id[count.index]
# }

# ##########################################
# # SSM Parameter - Public Subnet02 CIDR
# ##########################################
# resource "aws_ssm_parameter" "public_subnet02_cidr_output" {
#   count       = var.public_subnet02_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/public/subnet/02/cidr"
#   description = "Public Subnet 02 CIDR"
#   type        = "String"
#   value       = var.public_subnet02_cidr
# }

##########################################
# Public Subnet 03
##########################################
resource "aws_subnet" "public_subnet_3" {
  count      = var.public_subnet03_cidr == "N/A" ? 0 : 1
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet03_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[3]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-public-subnet-03"
    },
  )
}
# ##########################################
# # SSM Parameter - Public Subnet03 Id
# ##########################################
# resource "aws_ssm_parameter" "public_subnet03_id_output" {
#   count       = var.public_subnet03_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/public/subnet/03/id"
#   description = "Public Subnet 03 ID"
#   type        = "String"
#   value       = aws_subnet.public_subnet_3.*.id[count.index]
# }

# ##########################################
# # SSM Parameter - Public Subnet03 CIDR
# ##########################################
# resource "aws_ssm_parameter" "public_subnet03_cidr_output" {
#   count       = var.public_subnet03_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/public/subnet/03/cidr"
#   description = "Public Subnet 03 CIDR"
#   type        = "String"
#   value       = var.public_subnet03_cidr
# }

##########################################
# Public Subnet 04
##########################################
resource "aws_subnet" "public_subnet_4" {
  count      = var.public_subnet04_cidr == "N/A" ? 0 : 1
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet04_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[4]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-public-subnet-04"
    },
  )
}
# ##########################################
# # SSM Parameter - Public Subnet04 Id
# ##########################################
# resource "aws_ssm_parameter" "public_subnet04_id_output" {
#   count       = var.public_subnet04_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/public/subnet/04/id"
#   description = "Public Subnet 04 ID"
#   type        = "String"
#   value       = aws_subnet.public_subnet_4.*.id[count.index]
# }

# ##########################################
# # SSM Parameter - Public Subnet04 CIDR
# ##########################################
# resource "aws_ssm_parameter" "public_subnet04_cidr_output" {
#   count       = var.public_subnet04_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/public/subnet/04/cidr"
#   description = "Public Subnet 04 CIDR"
#   type        = "String"
#   value       = var.public_subnet04_cidr
# }

# ##########################################
# # SSM Parameter - Public Subnet Ids
# ##########################################
# resource "aws_ssm_parameter" "public_subnet_ids_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/public/subnets/id"
#   description = "Public Subnets ID"
#   type        = "String"
#   value       = join(",", aws_network_acl.public_nacl.subnet_ids)
# }

##########################################
# Private Subnets
##########################################

##########################################
# Private Subnet 0
##########################################
resource "aws_subnet" "private_subnet_0" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet00_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-private-subnet-00"
    },
  )
}
# ##########################################
# # SSM Parameter - Private Subnet00 Id
# ##########################################
# resource "aws_ssm_parameter" "private_subnet00_id_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/private/subnet/00/id"
#   description = "Private Subnet 00 ID"
#   type        = "String"
#   value       = aws_subnet.private_subnet_0.id
# }

# ##########################################
# # SSM Parameter - Private Subnet00 CIDR
# ##########################################
# resource "aws_ssm_parameter" "private_subnet00_cidr_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/private/subnet/00/cidr"
#   description = "Private Subnet 00 CIDR"
#   type        = "String"
#   value       = var.private_subnet00_cidr
# }

##########################################
# Private Subnet 01
##########################################
resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet01_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-private-subnet-01"
    },
  )
}
# ##########################################
# # SSM Parameter - Private Subnet01 Id
# ##########################################
# resource "aws_ssm_parameter" "private_subnet01_id_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/private/subnet/01/id"
#   description = "Private Subnet 01 ID"
#   type        = "String"
#   value       = aws_subnet.private_subnet_1.id
# }

# ##########################################
# # SSM Parameter - Public Subnet01 CIDR
# ##########################################
# resource "aws_ssm_parameter" "private_subnet01_cidr_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/private/subnet/01/cidr"
#   description = "Private Subnet 01 CIDR"
#   type        = "String"
#   value       = var.private_subnet01_cidr
# }

##########################################
# Private Subnet 02
##########################################
resource "aws_subnet" "private_subnet_2" {
  count      = var.private_subnet02_cidr == "N/A" ? 0 : 1
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet02_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-private-subnet-02"
    },
  )
}
# ##########################################
# # SSM Parameter - Private Subnet02 Id
# ##########################################
# resource "aws_ssm_parameter" "private_subnet02_id_output" {
#   count       = var.private_subnet02_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/private/subnet/02/id"
#   description = "Private Subnet 02 ID"
#   type        = "String"
#   value       = aws_subnet.private_subnet_2.*.id[count.index]
# }

# ##########################################
# # SSM Parameter - Private Subnet02 CIDR
# ##########################################
# resource "aws_ssm_parameter" "private_subnet02_cidr_output" {
#   count       = var.private_subnet02_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/private/subnet/02/cidr"
#   description = "Private Subnet 02 CIDR"
#   type        = "String"
#   value       = var.private_subnet02_cidr
# }

##########################################
# Private Subnet 03
##########################################
resource "aws_subnet" "private_subnet_3" {
  count      = var.private_subnet03_cidr == "N/A" ? 0 : 1
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet03_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[3]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-private-subnet-03"
    },
  )
}
# ##########################################
# # SSM Parameter - Private Subnet03 Id
# ##########################################
# resource "aws_ssm_parameter" "private_subnet03_id_output" {
#   count       = var.private_subnet03_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/private/subnet/03/id"
#   description = "Private Subnet 03 ID"
#   type        = "String"
#   value       = aws_subnet.private_subnet_3.*.id[count.index]
# }

# ##########################################
# # SSM Parameter - Private Subnet03 CIDR
# ##########################################
# resource "aws_ssm_parameter" "private_subnet03_cidr_output" {
#   count       = var.private_subnet03_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/private/subnet/03/cidr"
#   description = "Private Subnet 03 CIDR"
#   type        = "String"
#   value       = var.private_subnet03_cidr
# }

##########################################
# Private Subnet 04
##########################################
resource "aws_subnet" "private_subnet_4" {
  count      = var.private_subnet04_cidr == "N/A" ? 0 : 1
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet04_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[4]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-private-subnet-04"
    },
  )
}
# ##########################################
# # SSM Parameter - Private Subnet04 Id
# ##########################################
# resource "aws_ssm_parameter" "private_subnet04_id_output" {
#   count       = var.private_subnet04_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/private/subnet/04/id"
#   description = "Private Subnet 04 ID"
#   type        = "String"
#   value       = aws_subnet.private_subnet_4.*.id[count.index]
# }

# ##########################################
# # SSM Parameter - Private Subnet04 CIDR
# ##########################################
# resource "aws_ssm_parameter" "private_subnet04_cidr_output" {
#   count       = var.private_subnet04_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/private/subnet/04/cidr"
#   description = "Private Subnet 04 CIDR"
#   type        = "String"
#   value       = var.private_subnet04_cidr
# }

# ##########################################
# # SSM Parameter - Private Subnet Ids
# ##########################################
# resource "aws_ssm_parameter" "private_subnet_ids_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/private/subnets/id"
#   description = "Private Subnets ID"
#   type        = "String"
#   value       = join(",", aws_network_acl.private_nacl.subnet_ids)

# }

##########################################
# Protected Subnets
##########################################

##########################################
# Protected Subnet 0
##########################################
resource "aws_subnet" "protected_subnet_0" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.protected_subnet00_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-protected-subnet-00"
    },
  )
}
# ##########################################
# # SSM Parameter - Protected Subnet00 Id
# ##########################################
# resource "aws_ssm_parameter" "protected_subnet00_id_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/protected/subnet/00/id"
#   description = "Protected Subnet 00 ID"
#   type        = "String"
#   value       = aws_subnet.protected_subnet_0.id
# }

# ##########################################
# # SSM Parameter - Protected Subnet00 CIDR
# ##########################################
# resource "aws_ssm_parameter" "protected_subnet00_cidr_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/protected/subnet/00/cidr"
#   description = "Protected Subnet 00 CIDR"
#   type        = "String"
#   value       = var.protected_subnet00_cidr
# }

##########################################
# Protected Subnet 01
##########################################
resource "aws_subnet" "protected_subnet_1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.protected_subnet01_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-protected-subnet-01"
    },
  )
}
# ##########################################
# # SSM Parameter - Protected Subnet01 Id
# ##########################################
# resource "aws_ssm_parameter" "protected_subnet01_id_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/protected/subnet/01/id"
#   description = "Protected Subnet 01 ID"
#   type        = "String"
#   value       = aws_subnet.protected_subnet_1.id
# }

# ##########################################
# # SSM Parameter - Public Subnet01 CIDR
# ##########################################
# resource "aws_ssm_parameter" "protected_subnet01_cidr_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/protected/subnet/01/cidr"
#   description = "Protected Subnet 01 CIDR"
#   type        = "String"
#   value       = var.protected_subnet01_cidr
# }

##########################################
# Protected Subnet 02
##########################################
resource "aws_subnet" "protected_subnet_2" {
  count      = var.protected_subnet02_cidr == "N/A" ? 0 : 1
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.protected_subnet02_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-protected-subnet-02"
    },
  )
}
# ##########################################
# # SSM Parameter - Protected Subnet02 Id
# ##########################################
# resource "aws_ssm_parameter" "protected_subnet02_id_output" {
#   count       = var.protected_subnet02_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/protected/subnet/02/id"
#   description = "Protected Subnet 02 ID"
#   type        = "String"
#   value       = aws_subnet.protected_subnet_2.*.id[count.index]
# }

# ##########################################
# # SSM Parameter - Protected Subnet02 CIDR
# ##########################################
# resource "aws_ssm_parameter" "protected_subnet02_cidr_output" {
#   count       = var.protected_subnet02_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/protected/subnet/02/cidr"
#   description = "Protected Subnet 02 CIDR"
#   type        = "String"
#   value       = var.protected_subnet02_cidr
# }

##########################################
# Protected Subnet 03
##########################################
resource "aws_subnet" "protected_subnet_3" {
  count      = var.protected_subnet03_cidr == "N/A" ? 0 : 1
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.protected_subnet03_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[3]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-protected-subnet-03"
    },
  )
}
# ##########################################
# # SSM Parameter - Protected Subnet03 Id
# ##########################################
# resource "aws_ssm_parameter" "protected_subnet03_id_output" {
#   count       = var.protected_subnet03_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/protected/subnet/03/id"
#   description = "Protected Subnet 03 ID"
#   type        = "String"
#   value       = aws_subnet.protected_subnet_3.*.id[count.index]
# }

# ##########################################
# # SSM Parameter - Protected Subnet03 CIDR
# ##########################################
# resource "aws_ssm_parameter" "protected_subnet03_cidr_output" {
#   count       = var.protected_subnet03_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/protected/subnet/03/cidr"
#   description = "Protected Subnet 03 CIDR"
#   type        = "String"
#   value       = var.protected_subnet03_cidr
# }

##########################################
# Protected Subnet 04
##########################################
resource "aws_subnet" "protected_subnet_4" {
  count      = var.protected_subnet04_cidr == "N/A" ? 0 : 1
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.protected_subnet04_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[4]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-protected-subnet-04"
    },
  )
}
# ##########################################
# # SSM Parameter - Protected Subnet04 Id
# ##########################################
# resource "aws_ssm_parameter" "protected_subnet04_id_output" {
#   count       = var.protected_subnet04_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/protected/subnet/04/id"
#   description = "Protected Subnet 04 ID"
#   type        = "String"
#   value       = aws_subnet.protected_subnet_4.*.id[count.index]
# }

# ##########################################
# # SSM Parameter - Protected Subnet04 CIDR
# ##########################################
# resource "aws_ssm_parameter" "protected_subnet04_cidr_output" {
#   count       = var.protected_subnet04_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/protected/subnet/04/cidr"
#   description = "Protected Subnet 04 CIDR"
#   type        = "String"
#   value       = var.protected_subnet04_cidr
# }

# ##########################################
# # SSM Parameter - Protected Subnet Ids
# ##########################################
# resource "aws_ssm_parameter" "protected_subnet_ids_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/protected/subnets/id"
#   description = "Protected Subnets ID"
#   type        = "String"
#   value       = join(",", aws_network_acl.protected_nacl.subnet_ids)

# }


##########################################
# Services Subnets
##########################################

##########################################
# Services Subnet 0
##########################################
resource "aws_subnet" "services_subnet_0" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.services_subnet00_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-services-subnet-00"
    },
  )
}
# ##########################################
# # SSM Parameter - Services Subnet00 Id
# ##########################################
# resource "aws_ssm_parameter" "services_subnet00_id_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/services/subnet/00/id"
#   description = "Services Subnet 00 ID"
#   type        = "String"
#   value       = aws_subnet.services_subnet_0.id
# }

# ##########################################
# # SSM Parameter - Services Subnet00 CIDR
# ##########################################
# resource "aws_ssm_parameter" "services_subnet00_cidr_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/services/subnet/00/cidr"
#   description = "Services Subnet 00 CIDR"
#   type        = "String"
#   value       = var.services_subnet00_cidr
# }

##########################################
# Services Subnet 01
##########################################
resource "aws_subnet" "services_subnet_1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.services_subnet01_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-services-subnet-01"
    },
  )
}
# ##########################################
# # SSM Parameter - Services Subnet01 Id
# ##########################################
# resource "aws_ssm_parameter" "services_subnet01_id_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/services/subnet/01/id"
#   description = "Services Subnet 01 ID"
#   type        = "String"
#   value       = aws_subnet.services_subnet_1.id
# }

# ##########################################
# # SSM Parameter - Public Subnet01 CIDR
# ##########################################
# resource "aws_ssm_parameter" "services_subnet01_cidr_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/services/subnet/01/cidr"
#   description = "Services Subnet 01 CIDR"
#   type        = "String"
#   value       = var.services_subnet01_cidr
# }

##########################################
# Services Subnet 02
##########################################
resource "aws_subnet" "services_subnet_2" {
  count      = var.services_subnet02_cidr == "N/A" ? 0 : 1
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.services_subnet02_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-services-subnet-02"
    },
  )
}
# ##########################################
# # SSM Parameter - Services Subnet02 Id
# ##########################################
# resource "aws_ssm_parameter" "services_subnet02_id_output" {
#   count       = var.services_subnet02_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/services/subnet/02/id"
#   description = "Services Subnet 02 ID"
#   type        = "String"
#   value       = aws_subnet.services_subnet_2.*.id[count.index]
# }

# ##########################################
# # SSM Parameter - Services Subnet02 CIDR
# ##########################################
# resource "aws_ssm_parameter" "services_subnet02_cidr_output" {
#   count       = var.services_subnet02_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/services/subnet/02/cidr"
#   description = "Services Subnet 02 CIDR"
#   type        = "String"
#   value       = var.services_subnet02_cidr
# }

##########################################
# Services Subnet 03
##########################################
resource "aws_subnet" "services_subnet_3" {
  count      = var.services_subnet03_cidr == "N/A" ? 0 : 1
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.services_subnet03_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[3]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-services-subnet-03"
    },
  )
}
# ##########################################
# # SSM Parameter - Services Subnet03 Id
# ##########################################
# resource "aws_ssm_parameter" "services_subnet03_id_output" {
#   count       = var.services_subnet03_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/services/subnet/03/id"
#   description = "Services Subnet 03 ID"
#   type        = "String"
#   value       = aws_subnet.services_subnet_3.*.id[count.index]
# }

# ##########################################
# # SSM Parameter - Services Subnet03 CIDR
# ##########################################
# resource "aws_ssm_parameter" "services_subnet03_cidr_output" {
#   count       = var.services_subnet03_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/services/subnet/03/cidr"
#   description = "Services Subnet 03 CIDR"
#   type        = "String"
#   value       = var.services_subnet03_cidr
# }

##########################################
# Services Subnet 04
##########################################
resource "aws_subnet" "services_subnet_4" {
  count      = var.services_subnet04_cidr == "N/A" ? 0 : 1
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.services_subnet04_cidr
  # region of az based on provider
  availability_zone       = data.aws_availability_zones.available.names[4]
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-services-subnet-04"
    },
  )
}
# ##########################################
# # SSM Parameter - Services Subnet04 Id
# ##########################################
# resource "aws_ssm_parameter" "services_subnet04_id_output" {
#   count       = var.services_subnet04_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/services/subnet/04/id"
#   description = "Services Subnet 04 ID"
#   type        = "String"
#   value       = aws_subnet.services_subnet_4.*.id[count.index]
# }

# ##########################################
# # SSM Parameter - Services Subnet04 CIDR
# ##########################################
# resource "aws_ssm_parameter" "services_subnet04_cidr_output" {
#   count       = var.services_subnet04_cidr == "N/A" ? 0 : 1
#   name        = "/caylent/vpc${var.param_post_fix}/services/subnet/04/cidr"
#   description = "Services Subnet 04 CIDR"
#   type        = "String"
#   value       = var.services_subnet04_cidr
# }


# ##########################################
# # SSM Parameter - Services Subnet Ids
# ##########################################
# resource "aws_ssm_parameter" "services_subnet_ids_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/services/subnets/id"
#   description = "Services Subnets ID"
#   type        = "String"
#   value       = join(",", aws_network_acl.services_nacl.subnet_ids)
# }

##########################################
# Route Table Associations
##########################################
##########################################
# Public
##########################################
resource "aws_route_table_association" "public00" {
  subnet_id      = aws_subnet.public_subnet_0.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public01" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public02" {
  count          = var.public_subnet02_cidr == "N/A" ? 0 : 1
  subnet_id      = aws_subnet.public_subnet_2[0].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public03" {
  count          = var.public_subnet03_cidr == "N/A" ? 0 : 1
  subnet_id      = aws_subnet.public_subnet_3[0].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public04" {
  count          = var.public_subnet04_cidr == "N/A" ? 0 : 1
  subnet_id      = aws_subnet.public_subnet_4[0].id
  route_table_id = aws_route_table.public_route_table.id
}

##########################################
# Private
##########################################
resource "aws_route_table_association" "private00" {
  subnet_id      = aws_subnet.private_subnet_0.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private01" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private02" {
  count          = var.private_subnet02_cidr == "N/A" ? 0 : 1
  subnet_id      = aws_subnet.private_subnet_2[0].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private03" {
  count          = var.private_subnet03_cidr == "N/A" ? 0 : 1
  subnet_id      = aws_subnet.private_subnet_3[0].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private04" {
  count          = var.private_subnet04_cidr == "N/A" ? 0 : 1
  subnet_id      = aws_subnet.private_subnet_4[0].id
  route_table_id = aws_route_table.private_route_table.id
}

##########################################
# Services 
##########################################
resource "aws_route_table_association" "services00" {
  subnet_id      = aws_subnet.services_subnet_0.id
  route_table_id = aws_route_table.services_route_table.id
}

resource "aws_route_table_association" "services01" {
  subnet_id      = aws_subnet.services_subnet_1.id
  route_table_id = aws_route_table.services_route_table.id
}

resource "aws_route_table_association" "services02" {
  count          = var.services_subnet02_cidr == "N/A" ? 0 : 1
  subnet_id      = aws_subnet.services_subnet_2[0].id
  route_table_id = aws_route_table.services_route_table.id
}

resource "aws_route_table_association" "services03" {
  count          = var.services_subnet03_cidr == "N/A" ? 0 : 1
  subnet_id      = aws_subnet.services_subnet_3[0].id
  route_table_id = aws_route_table.services_route_table.id
}

resource "aws_route_table_association" "services04" {
  count          = var.services_subnet04_cidr == "N/A" ? 0 : 1
  subnet_id      = aws_subnet.services_subnet_4[0].id
  route_table_id = aws_route_table.services_route_table.id
}

##########################################
# Protected 
##########################################
resource "aws_route_table_association" "protected00" {
  subnet_id      = aws_subnet.protected_subnet_0.id
  route_table_id = aws_route_table.protected_route_table.id
}

resource "aws_route_table_association" "protected01" {
  subnet_id      = aws_subnet.protected_subnet_1.id
  route_table_id = aws_route_table.protected_route_table.id
}

resource "aws_route_table_association" "protected02" {
  count          = var.protected_subnet02_cidr == "N/A" ? 0 : 1
  subnet_id      = aws_subnet.protected_subnet_2[0].id
  route_table_id = aws_route_table.protected_route_table.id
}

resource "aws_route_table_association" "protected03" {
  count          = var.protected_subnet03_cidr == "N/A" ? 0 : 1
  subnet_id      = aws_subnet.protected_subnet_3[0].id
  route_table_id = aws_route_table.protected_route_table.id
}

resource "aws_route_table_association" "protected04" {
  count          = var.protected_subnet04_cidr == "N/A" ? 0 : 1
  subnet_id      = aws_subnet.protected_subnet_4[0].id
  route_table_id = aws_route_table.protected_route_table.id
}

##########################################
# NACL 
##########################################
##########################################
# Public NACL 
##########################################
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.public_subnet_0.id,
    aws_subnet.public_subnet_1.id,
    var.public_subnet02_cidr == "N/A" ? aws_subnet.public_subnet_1.id : aws_subnet.public_subnet_2[0].id,
    var.public_subnet03_cidr == "N/A" ? aws_subnet.public_subnet_1.id : aws_subnet.public_subnet_3[0].id,
    var.public_subnet04_cidr == "N/A" ? aws_subnet.public_subnet_1.id : aws_subnet.public_subnet_4[0].id,
  ]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-public-nacl"
    },
  )
}

# ##########################################
# # SSM Parameter - Public NACL Id
# ##########################################
# resource "aws_ssm_parameter" "public_nacl_id_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/public/nacl/id"
#   description = "Private NACL ID"
#   type        = "String"
#   value       = aws_network_acl.public_nacl.id
# }

##########################################
# Private NACL 
##########################################
resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.private_subnet_0.id,
    aws_subnet.private_subnet_1.id,
    var.private_subnet02_cidr == "N/A" ? aws_subnet.private_subnet_1.id : aws_subnet.private_subnet_2[0].id,
    var.private_subnet03_cidr == "N/A" ? aws_subnet.private_subnet_1.id : aws_subnet.private_subnet_3[0].id,
    var.private_subnet04_cidr == "N/A" ? aws_subnet.private_subnet_1.id : aws_subnet.private_subnet_4[0].id,
  ]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-private-nacl"
    },
  )
}

# ##########################################
# # SSM Parameter - Private NACL Id
# ##########################################
# resource "aws_ssm_parameter" "private_nacl_id_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/private/nacl/id"
#   description = "Private NACL ID"
#   type        = "String"
#   value       = aws_network_acl.private_nacl.id
# }

##########################################
# Protected NACL 
##########################################
resource "aws_network_acl" "protected_nacl" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.protected_subnet_0.id,
    aws_subnet.protected_subnet_1.id,
    var.protected_subnet02_cidr == "N/A" ? aws_subnet.protected_subnet_1.id : aws_subnet.protected_subnet_2[0].id,
    var.protected_subnet03_cidr == "N/A" ? aws_subnet.protected_subnet_1.id : aws_subnet.protected_subnet_3[0].id,
    var.protected_subnet04_cidr == "N/A" ? aws_subnet.protected_subnet_1.id : aws_subnet.protected_subnet_4[0].id,
  ]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-protected-nacl"
    },
  )
}

# ##########################################
# # SSM Parameter - Protected NACL Id
# ##########################################
# resource "aws_ssm_parameter" "protected_nacl_id_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/protected/nacl/id"
#   description = "Protected NACL ID"
#   type        = "String"
#   value       = aws_network_acl.protected_nacl.id
# }


##########################################
# Services NACL 
##########################################
resource "aws_network_acl" "services_nacl" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    "${aws_subnet.services_subnet_0.id}",
    "${aws_subnet.services_subnet_1.id}",
    var.services_subnet02_cidr == "N/A" ? aws_subnet.services_subnet_1.id : aws_subnet.services_subnet_2[0].id,
    var.services_subnet03_cidr == "N/A" ? aws_subnet.services_subnet_1.id : aws_subnet.services_subnet_3[0].id,
    var.services_subnet04_cidr == "N/A" ? aws_subnet.services_subnet_1.id : aws_subnet.services_subnet_4[0].id,
  ]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment_name}-services-nacl"
    },
  )
}

# ##########################################
# # SSM Parameter - Services NACL Id
# ##########################################
# resource "aws_ssm_parameter" "services_nacl_id_output" {
#   name        = "/caylent/vpc${var.param_post_fix}/services/nacl/id"
#   description = "Services NACL ID"
#   type        = "String"
#   value       = aws_network_acl.services_nacl.id
# }



