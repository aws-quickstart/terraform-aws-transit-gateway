# VPC
output "vpc_cidr" {
  description = "VPC_CIDR "
  value       = aws_vpc.main.cidr_block
}

output  "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "route_id" {
  value = aws_vpc.main.main_route_table_id
}

output "subnet_ids" {
  value = aws_subnet.public.*.id
}

output "NAT1EIP" {
    description = "NAT 1 IP address"
    value = aws_eip.nat[0].public_ip
}

output "NAT2EIP" {
    description = " NAT 2 IP address"
    value =  aws_eip.nat[1].public_ip
  }

output "NAT3EIP" {
    description = " NAT 3 IP address"
    value =  length(aws_eip.nat.*.public_ip) > 2 ? aws_eip.nat[2].public_ip : null
  }

output "NAT4EIP" {
    description = " NAT 4 IP address"
    value = length(aws_eip.nat.*.public_ip) > 3 ? aws_eip.nat[3].public_ip : null
  }

output "PublicSubnet1ID" {
    description = " Public subnet 1 ID in Availability Zone 1"
    value = aws_subnet.public[0].id
  }

output "PublicSubnet2CIDR" {
    description = " Public subnet 2 CIDR in Availability Zone 2"
    value =  aws_subnet.public[1].cidr_block
  }

output "PublicSubnet2ID" {
    description = " Public subnet 2 ID in Availability Zone 2"
    value = aws_subnet.public[1].id
  }

output "PublicSubnet3CIDR" {
    description = " Public subnet 3 CIDR in Availability Zone 3"
    value = length(aws_subnet.public.*.cidr_block) > 2 ? aws_subnet.public[2].cidr_block : null
  }

output "PublicSubnet3ID" {
    description = " Public subnet 3 ID in Availability Zone 3"
    value = length(aws_subnet.public.*.id) > 2 ? aws_subnet.public[2].id : null
  }

output "PublicSubnet4CIDR" {
    description = " Public subnet 4 CIDR in Availability Zone 4"
    value = length(aws_subnet.public.*.cidr_block) > 3 ? aws_subnet.public[3].cidr_block : null
  }

output "PublicSubnet4ID" {
    description = " Public subnet 4 ID in Availability Zone 4"
    value = length(aws_subnet.public.*.id) > 3 ? aws_subnet.public[3].id : null
  }

output  "PublicSubnetRouteTable" {
    description = " Public subnet route table"
    value = aws_route_table.public.id
  }