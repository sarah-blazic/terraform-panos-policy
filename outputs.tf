#tags
output "created_tags" {
  description = "Shows the tags that were created."
  value       = var.tags_file != "optional" ? { for tag in var.tags_file : tag.name => tag } : {}
}


#services
output "created_services" {
  description = "Shows the services that were created."
  value       = var.services_file != "optional" ? { for service in var.services_file : service.name => service } : {}
}


#address
output "created_addr_obj" {
  description = "Shows the address objects that were created."
  value       = var.addr_obj_file != "optional" ? { for obj in var.addr_obj_file : obj.name => obj } : tomap({})
}

output "created_addr_group" {
  description = "Shows the address groups that were created."
  value       = var.addr_group_file != "optional" ? { for group in var.addr_group_file : group.name => group } : tomap({})
}


#policy
output "created_sec" {
  description = "Shows the security policies that were created."
  value = var.sec_file != "optional" ? { for item in var.sec_file :
    "${try(item.device_group, "shared")}_${try(item.rulebase, "pre-rulebase")}_${try(item.position_keyword, "")}_${try(item.position_reference, "")}"
  => item } : tomap({})
}

output "created_nat" {
  description = "Shows the nat policies that were created."
  value = var.nat_file != "optional" ? { for item in var.nat_file :
    "${try(item.device_group, "shared")}_${try(item.rulebase, "pre-rulebase")}_${try(item.position_keyword, "")}_${try(item.position_reference, "")}"
  => item } : tomap({})
}

