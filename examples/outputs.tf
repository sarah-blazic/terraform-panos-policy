output "tags" {
  value = module.policy.created_tags
}

output "address_obj" {
  value = module.policy.created_addr_obj
}

output "address_group" {
  value = module.policy.created_addr_group
}

output "services" {
  value = module.policy.created_services
}

output "security" {
  value = module.policy.created_sec
}

output "nat" {
  value = module.policy.created_nat
}
