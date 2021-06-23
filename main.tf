locals {
  tags_f       = jsondecode(file("ex2_tags.json"))
  addr_obj_f   = jsondecode(file("ex2_addr_obj.json"))
  addr_group_f = jsondecode(file("ex1_addr_group.json"))
  service_f    = jsondecode(file("ex1_services.json"))
  sec_pol_f    = jsondecode(file("ex1_sec_policy.json"))

}

resource "panos_panorama_administrative_tag" "this" {
  for_each = {for tag in local.tags_f: tag.name => tag}

  name          = each.key
  color         = try(each.value.color, null)
  comment       = try(each.value.comment, null)
  device_group  = try(each.value.device_group, "shared")
}

resource "panos_address_object" "this" {
  for_each = {for obj in local.addr_obj_f: obj.name => obj}

  name           = each.key
  value          = lookup(each.value.value, each.value.type)
  type           = try(each.value.type, "ip-netmask")
  device_group   = try(each.value.device_group, "shared")
  description    = try(each.value.description, null)
  tags           = try(each.value.tags, null)
}

resource "panos_panorama_address_group" "this" {
  for_each = {for obj in local.addr_group_f: obj.name => obj}

  name              = each.key
  device_group      = try(each.value.device_group, "shared")
  static_addresses  = try(each.value.static_addresses, null)
  dynamic_match     = try(each.value.dynamic_match, null)
  description       = try(each.value.description, null)
  tags              = try(each.value.tags, null)
}

resource "panos_panorama_service_object" "this" {
  for_each = {for obj in local.service_f: obj.name => obj}

  destination_port             = lookup(each.value, "destination_port")
  name                         = each.key
  protocol                     = lookup(each.value, "protocol")
  device_group                 = try(each.value.device_group, "shared")
  description                  = try(each.value.description, null)
  source_port                  = try(each.value.source_port, null)
  tags                         = try(each.value.tags, null)
  override_session_timeout     = try(each.value.override_session_timeout, false)
  override_timeout             = try(each.value.override_timeout, null)
  override_half_closed_timeout = try(each.value.override_half_closed_timeout, null)
  override_time_wait_timeout   = try(each.value.override_time_wait_timeout, null)
}

//resource "panos_panorama_security_policy" "this" {
//  depends_on   = [panos_address_object.this, panos_panorama_administrative_tag.this]
//
//  for_each = {for item in local.sec_pol_f: item.device_group => item}
//  device_group = try(each.value.device_group, "shared")
//  rulebase = try(each.value.rulebase, "pre-rulebase")

//  dynamic "rule" {
////    for_each = { for policy in local.sec_pol_f.rules : policy.name => policy }
////    for_each = flatten([
////      for policy, hi in local.sec_pol_f : [
////        for name, property in hi : [
////          merge({ "property" = property }, { "name" = name })
//////          zipmap(
//////            [name],[property]
//////          )
////        ]
////      ]
////    ])
//
//    content {
//      applications                       = lookup(rule.value, "applications", ["any"])
//      categories                         = lookup(rule.value, "categories", ["any"])
//      destination_addresses              = lookup(rule.value, "destination_addresses", ["any"])
//      destination_zones                  = lookup(rule.value, "destination_zones", ["any"])
//      hip_profiles                       = lookup(rule.value, "hip_profiles", ["any"])
//      name                               = rule.value.name
//      services                           = lookup(rule.value, "services", ["application-default"])
//      source_addresses                   = lookup(rule.value, "source_addresses", ["any"])
//      source_users                       = lookup(rule.value, "source_users", ["any"])
//      source_zones                       = lookup(rule.value, "source_zones", ["any"])
//      description                        = lookup(rule.value, "description", null)
//      tags                               = lookup(rule.value,"tags", null)
////      type                               = lookup(rule.value, "type", "universal")
////      negate_source                      = lookup(rule.value, "negate_source", false)
////      negate_destination                 = lookup(rule.value, "negate_destination", false)
////      action                             = lookup(rule.value, "action", "allow")
////      log_setting                        = ""
////      log_start                          = ""
////      log_end                            = ""
////      disabled                           = ""
////      schedule                           = ""
////      icmp_unreachable                   = ""
////      disable_server_response_inspection = ""
////      group                              = ""
////      virus                              = ""
////      spyware                            = ""
////      vulnerability                      = ""
////      url_filtering                      = ""
////      file_blocking                      = ""
////      wildfire_analysis                  = ""
////      data_filtering                     = ""
////
////      target {
////        serial = ""
////        vsys_list = []
////      }
////      negate_target = ""
////    }
//  }
//}


//resource "panos_panorama_security_policy" "this" {
//  for_each = { for policy in local.sec_pol_f : policy.rule.name => policy }
//
//  device_group = try(each.value.device_group, "shared")
//  rulebase = try(each.value.rulebase, "pre-rulebase")
//
//  rule {
//    applications          = lookup(each.value, "applications", ["any"])
//    categories            = lookup(each.value, "categories", ["any"])
//    destination_addresses = lookup(each.value, "destination_addresses", ["any"])
//    destination_zones     = lookup(each.value, "destination_zones", ["any"])
//    hip_profiles          = lookup(each.value, "hip_profiles", ["any"])
//    name                  = each.key
//    services              = lookup(each.value, "services", ["application-default"])
//    source_addresses      = lookup(each.value, "source_addresses", ["any"])
//    source_users          = lookup(each.value, "source_users", ["any"])
//    source_zones          = lookup(each.value, "source_zones", ["any"])
//    description           = lookup(each.value, "description", null)
//  }
//}
