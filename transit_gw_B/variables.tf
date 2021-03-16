
# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "regionA" {
  type        = string
  description = "The name of the region you wish to deploy into"
}

variable "regionB" {
  type        = string
  description = "The name of the region you wish to deploy into"
}

variable "name" {
  type        = string
  description = "unique name for your resources"
}

variable "cidr_c" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "10.2.0.0/16"
}

variable "cidr_shared_services" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets_c" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = ["10.2.2.0/24", "10.2.3.0/24"]
}

