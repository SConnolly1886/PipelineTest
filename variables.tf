variable "region" {
  type        = string
  description = "Target region"
  default     = "us-east-1"
}

variable "account" {
  type        = string
  description = "Target AWS account number"
  default = "arn:aws:iam::587194664462:role/InfraBuildRole"
}

variable "env" {
  type        = string
  description = "Environment name"
  default = "dev"
}

variable "team" {
  type        = string
  description = "Team name"
  default = "research"
}