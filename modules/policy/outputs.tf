#tags
output "created_tags" {
  #for yaml files change jsondecode => yamldecode
  value = var.tags_file != "optional" ? { for tag in var.tags_file : tag.name => tag } : {}
}


#services
output "created_services" {
  #for yaml files change jsondecode => yamldecode
  value = var.services_file != "optional" ? { for service in var.services_file : service.name => service } : tomap({})
}


#address
output "created_addr_obj" {
  #for yaml files change jsondecode => yamldecode
  value = var.addr_obj_file != "optional" ? { for obj in var.addr_obj_file : obj.name => obj } : tomap({})
}

output "created_addr_group" {
  #for yaml files change jsondecode => yamldecode
  value = var.addr_group_file != "optional" ? { for group in var.addr_group_file : group.name => group } : tomap({})
}





#policy
output "created_sec" {
  #for yaml files change jsondecode => yamldecode
  value = var.sec_file != "optional" ? { for item in var.sec_file :
    "${try(item.device_group, "shared")}_${try(item.rulebase, "pre-rulebase")}_${try(item.position_keyword, "")}_${try(item.position_reference, "")}"
  => item } : tomap({})
}

output "created_nat" {
  #for yaml files change jsondecode => yamldecode
  value = var.nat_file != "optional" ? { for item in var.nat_file :
    "${try(item.device_group, "shared")}_${try(item.rulebase, "pre-rulebase")}_${try(item.position_keyword, "")}_${try(item.position_reference, "")}"
  => item } : tomap({})
}

#test for bug fix
output "target" {
  value = { for i in local.target_loop : i.name => i }
}
