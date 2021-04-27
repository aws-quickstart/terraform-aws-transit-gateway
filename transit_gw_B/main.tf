
# ---------------------------------------------------------------------------------------------------------------------
# Set the AWS REGION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = var.regionB
}

provider "aws" {
  alias  = "accepter"
  region = var.regionA
}

data "aws_availability_zones" "all" {}


data "aws_vpc" "vpc_shared_services_vpc" {
  provider = aws.accepter
  filter {
    name   = "tag:Name"
    values = ["${var.name}_shared_services_vpc"]
  }
  depends_on = [module.vpc_c.vpc_id]
}

data "aws_route_table" "vpc_shared_services" {
  provider   = aws.accepter
  depends_on = [aws_vpc_peering_connection.peer]
  vpc_id     = data.aws_vpc.vpc_shared_services_vpc.id
  filter {
    name   = "tag:Name"
    values = ["${var.name}_shared_services_public_routes"]
  }
}

resource "random_id" "name" {
  byte_length = 4
  prefix      = "aws-quickstart-"
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "aws_key_pair" "main" {
  key_name_prefix = random_id.name.hex
  public_key      = tls_private_key.key.public_key_openssh
}

# ---------------------------------------------------------------------------------------------------------------------
# Create the basic network via terrafrom registery VPC module
# ---------------------------------------------------------------------------------------------------------------------

module "vpc_c" {
  source = "../modules/private_vpc"
  region = var.regionB
  name   = "${var.name}_C"
  cidr   = var.cidr_c

  enable_dns_hostnames = true
  enable_dns_support   = true
  private_subnets      = var.private_subnets_c
}

# Add routes for intra-region  VPC routing
resource "aws_route" "route_vpc_c_to_shared_services" {
  route_table_id            = module.vpc_c.PrivateSubnet1ARouteTable
  destination_cidr_block    = var.cidr_shared_services
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "route_vpc_2c_to_shared_services" {
  route_table_id            = module.vpc_c.PrivateSubnet2ARouteTable
  destination_cidr_block    = var.cidr_shared_services
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "route_vpc_shared_services_to_vpc_c" {
  provider                  = aws.accepter
  route_table_id            = data.aws_route_table.vpc_shared_services.id
  destination_cidr_block    = var.cidr_c
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

#Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = module.vpc_c.vpc_id
  peer_vpc_id = data.aws_vpc.vpc_shared_services_vpc.id
  auto_accept = false
  peer_region = var.regionA

  tags = {
    Side = "Requester"
    Name = var.name
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
    Name = var.name
  }
}