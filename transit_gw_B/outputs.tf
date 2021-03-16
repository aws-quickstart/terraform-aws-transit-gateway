output "user_instructions" {
  value = <<README
To use the created ssh keys, perfrom the following command to copy the output of the key to a file locallaly on your machine.

terraform output ssh_key_primary    | cat >> first_key.pem
terraform output ssh_key_secondary  | cat >> second_key.pem

you can then use it to connect to the public jumphost using ssh -i first_key.pem ec2-user@public_ip_address

You can will have to copy the keys onto this jumphost to connect to the other instances.


README
}


output "private_key_pem" {
  value = tls_private_key.key.private_key_pem
}

output "jumphost_region_A_private" {
  value = data.aws_instances.hosts_regionA.private_ips
}

output "jumphost_region_A_public" {
  value = data.aws_instances.hosts_regionB.public_ips
}

output "jumphost_region_B_private" {
  value = data.aws_instances.hosts_regionB.private_ips
}