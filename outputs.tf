//////#outputs
//output "translated" {
//  for_each = {for item in local.nat_f:
//  "${try(item.device_group, "shared")}_${try(item.rulebase, "pre-rulebase")}_${try(item.position_keyword, "")}_${try(item.position_reference, "")}"
//  => item}
//
//   for_each = { for policy in each.value.rules : policy.name => policy }
//
//  value = each.value.each.value.translated_packet
//}

#module outputs
//output "created_tags" {
//  value = module.tags_mod.created_tags
//}
//
//output "created_services" {
//  value = module.services_mod.created_services
//}
