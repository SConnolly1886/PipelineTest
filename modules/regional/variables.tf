#########################################
# Application
#########################################
variable "account" {
  type = string
  description = "AWS account number"
  default = "arn:aws:iam::587194664462:role/InfraBuildRole"
}

variable "region" {
  type = string
  description = "region"
}

variable "env" {
  type = string
  description = "Environment"
}

variable "team" {
  type = string
  description = "Team name"
}

