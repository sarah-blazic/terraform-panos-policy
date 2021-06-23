locals {
  tags_f = jsondecode(file("ex2_tags.json"))
  addr_obj_f = jsondecode(file("ex2_addr_obj.json"))
  sec_pol_f = jsondecode(file("ex3_sec_policy.json"))

}

resource "panos_panorama_administrative_tag" "this" {
  for_each = {for tag in local.tags_f: tag.name => tag}

  name          = each.key
  color         = try(each.value.color, null)
  comment       = try(each.value.comment, null)
  device_group  = try(each.value.device_group, null)
}

resource "panos_address_object" "this" {
  for_each = {for obj in local.addr_obj_f: obj.name => obj}

  name           = each.key
  value          = lookup(each.value.value, each.value.type)
  type           = try(each.value.type, "ip-netmask")
  device_group   = try(each.value.device_group, null)
  description    = try(each.value.description, null)
  tags           = try(each.value.tags, null)
}

//resource "panos_panorama_security_policy_group" "this" {
//  depends_on   = [panos_address_object.this, panos_panorama_administrative_tag.this]
//
//  for_each = {for item in local.sec_pol_f: item.device_group => item}
//  device_group = try(each.value.device_group, "shared")
//  rulebase = try(each.value.rulebase, "pre-rulebase")
//
//  dynamic "rule" {
//    for_each = { for policy in local.sec_pol_f.rules : policy.name => policy }
//
//    content {
//      applications          = lookup(rule.value, "applications", ["any"])
//      categories            = lookup(rule.value, "categories", ["any"])
//      destination_addresses = lookup(rule.value, "destination_addresses", ["any"])
//      destination_zones     = lookup(rule.value, "destination_zones", ["any"])
//      hip_profiles          = lookup(rule.value, "hip_profiles", ["any"])
//      name                  = rule.key
//      services              = lookup(rule.value, "services", ["application-default"])
//      source_addresses      = lookup(rule.value, "source_addresses", ["any"])
//      source_users          = lookup(rule.value, "source_users", ["any"])
//      source_zones          = lookup(rule.value, "source_zones", ["any"])
//      description           = lookup(rule.value, "description", "hello?")
//      tags                  = lookup(rule.value,"tags", null)
//      type                  = lookup(rule.value, "type", "universal")
//      negate_source         = lookup(rule.value, "negate_source", false)
//      negate_destination    = lookup(rule.value, "negate_destination", false)
//      action                = lookup(rule.value, "action", "allow")
//      log_setting = lookup(, )
//    }
//  }
//}


