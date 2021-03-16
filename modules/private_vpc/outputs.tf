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
  value = aws_subnet.private_A.*.id
}

output "route_ids" {
  value = aws_route_table.private_A.*.id
}

output "PrivateSubnet1ACIDR" {
    description = " Private subnet 1A CIDR in Availability Zone 1"
    value = aws_subnet.private_A[0].cidr_block
  }

output "PrivateSubnet1AID" {
    description = " Private subnet 1A ID in Availability Zone 1"
    value =  aws_subnet.private_A[0].id
  }

output "PrivateSubnet2ACIDR" {
    description = " Private subnet 2A CIDR in Availability Zone 2"
    value = aws_subnet.private_A[1].cidr_block
  }

output "PrivateSubnet2AID" {
    description = " Private subnet 2A ID in Availability Zone 2"
    value = aws_subnet.private_A[1].id
  }

output "PrivateSubnet3ACIDR" {
    description = " Private subnet 3A CIDR in Availability Zone 3"
    value = length(aws_subnet.private_A.*.cidr_block) > 2 ? aws_subnet.private_A[2].cidr_block : null
  }

output "PrivateSubnet3AID" {
    description = " Private subnet 3A ID in Availability Zone 3"
    value = length(aws_subnet.private_A.*.id) > 2 ? aws_subnet.private_A[2].id : null
  }

output "PrivateSubnet4ACIDR" {
    description = " Private subnet 4A CIDR in Availability Zone 4"
    value = length(aws_subnet.private_A.*.cidr_block) > 3 ? aws_subnet.private_A[3].cidr_block : null
  }

output "PrivateSubnet4AID" {
    description = " Private subnet 4A ID in Availability Zone 4"
    value = length(aws_subnet.private_A.*.id) > 3 ? aws_subnet.private_A[3].id : null
  }

output "S3VPCEndpoint" {
    description = " Dynamo DB VPC Endpoint"
    value = aws_vpc_endpoint.s3.*.id
  }

output "PrivateSubnet1ARouteTable" {
    description = " Private subnet 1A route table"
    value = aws_route_table.private_A[0].id
  }

output "PrivateSubnet2ARouteTable" {
    description = " Private subnet 2A route table"
    value = aws_route_table.private_A[1].id
  }

output "PrivateSubnet3ARouteTable" {
    description = " Private subnet 3A route table"
    value = length(aws_route_table.private_A.*.id ) > 2 ? aws_route_table.private_A[2].id  : null 
  }

output "PrivateSubnet4ARouteTable" {
    description = " Private subnet 4A route table"
    value = length(aws_route_table.private_A.*.id ) > 3 ? aws_route_table.private_A[3].id  : null 
  }