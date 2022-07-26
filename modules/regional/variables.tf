variable "database_name" {
    description = "Name of Database cluster"
    default = "forresterdb"
  
}

variable "region" {
  type        = string
  description = "Target region"
#   default     = "us-east-1"
}

variable "account" {
  type        = string
  description = "Target AWS account number"
#   default = "arn:aws:iam::587194664462:role/InfraBuildRole"
}

variable "env" {
  type        = string
  description = "Environment name"
#   default = "dev"
}

variable "team" {
  type        = string
  description = "Team name"
#   default = "research"
}

variable "region_mapping" {
  description = "mapping for cross-region replication"
  default = {
    "us-east-1" = "us-east-2",
    "us-east-2" = "us-east-1",
    "ap-southeast-1" = "ap-south-1",
    "ap-south-1" = "ap-southeast-1",
    "eu-west-2" = "eu-west-3",
    "eu-west-3" = "eu-west-2"
  }
}

# CT regions: us-east-1, us-east-2, ap-southeast-1, ap-south-1, eu-west-2, eu-west-3