output "ssh_key_primary" {
    value = module.transit_gateway_primary.private_key_pem
}

output "ssh_key_secondary" {
    value = module.tranist_gateway_secondary.private_key_pem
}

output "jumphost_region_B_private" {
  value = module.tranist_gateway_secondary.jumphost_region_A_private
}

output "jumphost_region_A_public" {
  value = module.tranist_gateway_secondary.jumphost_region_A_public
}

output "jumphost_region_A" {
  value = module.tranist_gateway_secondary.jumphost_region_B_private
}