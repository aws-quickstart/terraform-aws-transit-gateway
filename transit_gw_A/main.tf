
# ---------------------------------------------------------------------------------------------------------------------
# Set the AWS REGION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = var.regionA
}

data "aws_availability_zones" "all" {}

resource "random_id" "name" {
  byte_length = 4
  prefix      = "aws-quickstart-"
}

resource "tls_private_key" "key" {
  algorithm   = "RSA"
  rsa_bits    = "2048"
}

resource "aws_key_pair" "main" {
  key_name_prefix = random_id.name.hex
  public_key      = tls_private_key.key.public_key_openssh
}

# ---------------------------------------------------------------------------------------------------------------------
# Create the basic network via terrafrom registery VPC module
# ---------------------------------------------------------------------------------------------------------------------

module "vpc_a" {
  source = "../modules/private_vpc"
  region = var.regionA
  name   = "${var.name}_A"
  cidr   = var.cidr_a

  enable_dns_hostnames = true
  enable_dns_support   = true
  private_subnets       = var.private_subnets_a
}

module "vpc_b" {
  source = "../modules/private_vpc"
  region = var.regionA
  name   = "${var.name}_B"
  cidr   = var.cidr_b

  enable_dns_hostnames = true
  enable_dns_support   = true
  private_subnets       = var.private_subnets_b
}

module "vpc_shared_services" {
  source = "../modules/public_vpc"
  region = var.regionA
  name   = "${var.name}_shared_services"
  cidr   = var.cidr_shared_services

  enable_dns_hostnames = true
  enable_dns_support   = true
  public_subnets       = var.public_subnets_shared_services
}

# ######################################
# Create jump hosts in shared_services
######################################
module "jumphost_primary" {
  depends_on = [module.vpc_shared_services]
  source = "../modules/jumphost"
  region = var.regionA
  name   = "${var.name}_shared_services"
  subnet_name = "${var.name}_shared_services_public_subnets"
  key_name = aws_key_pair.main.id
}

######################################
# Create jump hosts in vpc_a
######################################
module "jumphost_secondary" {
  depends_on = [module.vpc_a]
  source = "../modules/jumphost"
  region = var.regionA
  name   = "${var.name}_A"
  key_name = aws_key_pair.main.id
  subnet_name = "${var.name}_A_private_subnets"
}

######################################
# Create jump hosts in vpc_a
######################################
module "jumphost_third" {
  depends_on = [module.vpc_b]
  source = "../modules/jumphost"
  region = var.regionA
  name   = "${var.name}_B"
  key_name = aws_key_pair.main.id
  subnet_name = "${var.name}_B_private_subnets"
}

#create transit gateway for region A

resource "aws_ec2_transit_gateway" "region_A-tgw" {
  description                     = "Transit Gateway scenario with multiple VPCs."
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "${var.name}tgw_A"
  }
}

# attach transit GW to VPC_A

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-region_A" {
  subnet_ids                                      = module.vpc_a.subnet_ids
  transit_gateway_id                              = aws_ec2_transit_gateway.region_A-tgw.id
  vpc_id                                          = module.vpc_a.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "tgw-region-1-vpc_a"
  }
  depends_on = [aws_ec2_transit_gateway.region_A-tgw]
}

# attach transit GW to VPC_B
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-region_B" {
  subnet_ids                                      = module.vpc_b.subnet_ids
  transit_gateway_id                              = aws_ec2_transit_gateway.region_A-tgw.id
  vpc_id                                          = module.vpc_b.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "tgw-att-vpc_b"
  }
  depends_on = [aws_ec2_transit_gateway.region_A-tgw]
}

# attach transit GW to VPC_shared_services
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-region_shared_services" {
  subnet_ids                                      = module.vpc_shared_services.subnet_ids
  transit_gateway_id                              = aws_ec2_transit_gateway.region_A-tgw.id
  vpc_id                                          = module.vpc_shared_services.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "tgw-att-vpc_shared_services"
  }
  depends_on = [aws_ec2_transit_gateway.region_A-tgw]
}
# Route Tables

resource "aws_ec2_transit_gateway_route_table" "tgw-att-vpc_a-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.region_A-tgw.id
  tags = {
    Name = "tgw-att-vpc_a-rt"
  }
  depends_on = [aws_ec2_transit_gateway.region_A-tgw]
}

resource "aws_ec2_transit_gateway_route_table" "tgw-att-vpc_b-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.region_A-tgw.id
  tags = {
    Name = "tgw-att-vpc_b-rt"
  }
  depends_on = [aws_ec2_transit_gateway.region_A-tgw]
}

resource "aws_ec2_transit_gateway_route_table" "tgw-att-vpc_shared_services-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.region_A-tgw.id
  tags = {
    Name = "tgw-att-vpc_shared_services-rt"
  }
  depends_on = [aws_ec2_transit_gateway.region_A-tgw]
}


# Add routes for intra VPC routing

resource "aws_route" "route_shared_service_to_vpc_a" {
  route_table_id         = module.vpc_shared_services.PublicSubnetRouteTable
  destination_cidr_block = var.cidr_a
  transit_gateway_id     = aws_ec2_transit_gateway.region_A-tgw.id
}

resource "aws_route" "route_shared_service_to_vpc_b" {
  route_table_id         = module.vpc_shared_services.PublicSubnetRouteTable
  destination_cidr_block = var.cidr_b
  transit_gateway_id     = aws_ec2_transit_gateway.region_A-tgw.id
}

resource "aws_route" "route_vpc_a_to_shared_services" {
  route_table_id         = module.vpc_a.PrivateSubnet1ARouteTable
  destination_cidr_block = var.cidr_shared_services
  transit_gateway_id     = aws_ec2_transit_gateway.region_A-tgw.id
}

resource "aws_route" "route_vpc_b_to_shared_services" {
  route_table_id         = module.vpc_b.PrivateSubnet1ARouteTable
  destination_cidr_block = var.cidr_shared_services
  transit_gateway_id     = aws_ec2_transit_gateway.region_A-tgw.id
}

resource "aws_route" "route_vpc_2a_to_shared_services" {
  route_table_id         = module.vpc_a.PrivateSubnet2ARouteTable
  destination_cidr_block = var.cidr_shared_services
  transit_gateway_id     = aws_ec2_transit_gateway.region_A-tgw.id
}

resource "aws_route" "route_vpc_2b_to_shared_services" {
  route_table_id         = module.vpc_b.PrivateSubnet2ARouteTable
  destination_cidr_block = var.cidr_shared_services
  transit_gateway_id     = aws_ec2_transit_gateway.region_A-tgw.id
}


# # Route Tables Associations

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-a-assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-region_A.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-att-vpc_a-rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-b-assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-region_B.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-att-vpc_b-rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-shared_services-assoc" {
  transit_gateway_attachment_id  =  aws_ec2_transit_gateway_vpc_attachment.tgw-att-region_shared_services.id
  transit_gateway_route_table_id =  aws_ec2_transit_gateway_route_table.tgw-att-vpc_shared_services-rt.id
}

# # Route Tables Propagations

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-vpc-a" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-region_A.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-att-vpc_a-rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared_services-vpc-a" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-region_A.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-att-vpc_shared_services-rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-vpc-b" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-region_B.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-att-vpc_b-rt.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared_services-vpc-b" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-region_B.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-att-vpc_shared_services-rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-vpc-shared_services" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-region_shared_services.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-att-vpc_shared_services-rt.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-vpc-shared_services-vpc-a" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-region_shared_services.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-att-vpc_a-rt.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-vpc-shared_services-vpc-b" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-region_shared_services.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-att-vpc_b-rt.id
}

