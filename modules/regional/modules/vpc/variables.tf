
variable "environment_name" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "param_post_fix" {
  type        = string
  description = "Post fix for parameters"
  default     = ""
}

variable "vpc_cidr" {
  type        = string
  description = "IP Range for this VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet00_cidr" {
  type        = string
  description = "PubSubnet CIDR 0"
  default     = "10.0.0.0/24"
}

variable "public_subnet01_cidr" {
  type        = string
  description = "PubSubnet CIDR 1"
  default     = "10.0.1.0/24"
}

variable "public_subnet02_cidr" {
  type        = string
  description = "PubSubnet CIDR 2"
  default     = "N/A" # "10.0.2.0/24" "N/A"
}

variable "public_subnet03_cidr" {
  type        = string
  description = "PubSubnet CIDR 3"
  default     = "N/A" # "10.0.3.0/24" "N/A"
}

variable "public_subnet04_cidr" {
  type        = string
  description = "PubSubnet CIDR 4"
  default     = "N/A" # "10.0.4.0/24" "N/A"
}

variable "private_subnet00_cidr" {
  type        = string
  description = "PrivSubnet CIDR 0"
  default     = "10.0.10.0/24"
}

variable "private_subnet01_cidr" {
  type        = string
  description = "PrivSubnet CIDR 1"
  default     = "10.0.11.0/24"
}

variable "private_subnet02_cidr" {
  type        = string
  description = "PrivSubnet CIDR 2"
  default     = "N/A" # "10.0.12.0/24"
}

variable "private_subnet03_cidr" {
  type        = string
  description = "PrivSubnet CIDR 3"
  default     = "N/A" # "10.0.13.0/24" "N/A"
}

variable "private_subnet04_cidr" {
  type        = string
  description = "PrivSubnet CIDR 4"
  default     = "N/A" # "10.0.14.0/24" "N/A"
}

variable "protected_subnet00_cidr" {
  type        = string
  description = "ProtectedSubnet CIDR 0"
  default     = "10.0.20.0/24"
}

variable "protected_subnet01_cidr" {
  type        = string
  description = "ProtectedSubnet CIDR 1"
  default     = "10.0.21.0/24"
}

variable "protected_subnet02_cidr" {
  type        = string
  description = "ProtectedSubnet CIDR 2"
  default     = "N/A" # "10.0.22.0/24" "N/A"
}

variable "protected_subnet03_cidr" {
  type        = string
  description = "ProtectedSubnet CIDR 3"
  default     = "N/A" # "10.0.23.0/24" "N/A"
}

variable "protected_subnet04_cidr" {
  type        = string
  description = "ProtectedSubnet CIDR 4"
  default     = "N/A" # "10.0.24.0/24" "N/A"
}

variable "services_subnet00_cidr" {
  type        = string
  description = "ServicesSubnet CIDR 0"
  default     = "10.0.30.0/24"
}

variable "services_subnet01_cidr" {
  type        = string
  description = "ServicesSubnet CIDR 1"
  default     = "10.0.31.0/24"
}

variable "services_subnet02_cidr" {
  type        = string
  description = "ServicesSubnet CIDR 2"
  default     = "N/A" # "10.0.32.0/24" "N/A"
}

variable "services_subnet03_cidr" {
  type        = string
  description = "ServicesSubnet CIDR 3"
  default     = "N/A" # "10.0.33.0/24" "N/A"
}
variable "services_subnet04_cidr" {
  type        = string
  description = "ServicesSubnet CIDR 4"
  default     = "N/A" #"10.0.34.0/24" "N/A"
}

variable "log_bucket" {
  type        = string
  description = "VPC Flow logs bucket"
}
