######################################
# Defaults
######################################
terraform {
  required_version = ">= 0.15.1"

  backend "remote" {}
}

variable "main_region" {
  type    = string
  default = "us-west-1"
}

variable "secondary_region" {
  type    = string
  default = "us-west-2"
}

provider "aws" {
  region = var.main_region
}

provider "aws" {
  alias  = "accepter"
  region = var.secondary_region
}

resource "random_pet" "name" {
  prefix = "tfm-aws"
  length = 1
}

######################################
# Create VPC_A, VPC_B and Shared_service in region A
######################################

module "transit_gateway_primary" {
  source  = "../transit_gw_A"
  regionA = var.main_region
  name    = random_pet.name.id
}

######################################
# Create VPC_C in region B
######################################

module "tranist_gateway_secondary" {
  source  = "../transit_gw_B"
  regionA = var.main_region
  regionB = var.secondary_region
  name    = random_pet.name.id
}