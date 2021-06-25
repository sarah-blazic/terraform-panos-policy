locals {
//  tags_f       = jsondecode(file("ex2_tags.json"))
  addr_obj_f   = jsondecode(file("ex2_addr_obj.json"))
  addr_group_f = jsondecode(file("ex1_addr_group.json"))
//  service_f    = jsondecode(file("ex1_services.json"))
  sec_pol_f    = jsondecode(file("ex3_sec_policy.json"))

}

module "tags_mod" {
  source = "./modules/tags"
  tags_file = var.tags_f
}

resource "panos_address_object" "this" {
  for_each = {for obj in local.addr_obj_f : obj.name => obj}

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

module "services_mod" {
  source = "./modules/services"
  services_file = var.services_f
}

resource "panos_panorama_security_policy" "this" {
 // depends_on   = [panos_address_object.this, panos_panorama_administrative_tag.this]
  depends_on   = [panos_address_object.this, module.tags_mod]

  for_each = {for item in local.sec_pol_f: "${item.device_group}_${item.rulebase}" => item}

  device_group = try(each.value.device_group, "shared")
  rulebase = try(each.value.rulebase, "pre-rulebase")
  dynamic "rule" {
    for_each = { for policy in each.value.rules : policy.name => policy }
    content {
      applications                       = lookup(rule.value, "applications", ["any"])
      categories                         = lookup(rule.value, "categories", ["any"])
      destination_addresses              = lookup(rule.value, "destination_addresses", ["any"])
      destination_zones                  = lookup(rule.value, "destination_zones", ["any"])
      hip_profiles                       = lookup(rule.value, "hip_profiles", ["any"])
      name                               = rule.value.name
      services                           = lookup(rule.value, "services", ["application-default"])
      source_addresses                   = lookup(rule.value, "source_addresses", ["any"])
      source_users                       = lookup(rule.value, "source_users", ["any"])
      source_zones                       = lookup(rule.value, "source_zones", ["any"])
      description                        = lookup(rule.value, "description", null)
      tags                               = lookup(rule.value,"tags", null)
      type                               = lookup(rule.value, "type", "universal")
      negate_source                      = lookup(rule.value, "negate_source", false)
      negate_destination                 = lookup(rule.value, "negate_destination", false)
      action                             = lookup(rule.value, "action", "allow")
      log_setting                        = lookup(rule.value, "log_setting", null)
      log_start                          = lookup(rule.value, "log_start", false)
      log_end                            = lookup(rule.value, "log_end", true)
      disabled                           = lookup(rule.value, "disabled", false)
      schedule                           = lookup(rule.value, "schedule", null)
      icmp_unreachable                   = lookup(rule.value, "icmp_unreachable", null)
      disable_server_response_inspection = lookup(rule.value, "disable_server_response_inspection", false)
      group                              = lookup(rule.value, "group", null)
      virus                              = lookup(rule.value, "virus", null)
      spyware                            = lookup(rule.value, "spyware", null)
      vulnerability                      = lookup(rule.value, "vulnerability", null)
      url_filtering                      = lookup(rule.value, "url_filtering", null)
      file_blocking                      = lookup(rule.value, "file_blocking", null)
      wildfire_analysis                  = lookup(rule.value, "wildfire_analysis", null)
      data_filtering                     = lookup(rule.value, "data_filtering", null)

//      dynamic target {
////        for_each = { for t in rule.value.target : t.serial => t }
//        for_each = { for t in rule.value : t => t }
//        content {
//          serial = target.value.serial
//          vsys_list = lookup(target.value, "vsys_list", null)
//        }
//      }
      negate_target = lookup(rule.value, "negate_target", false)
    }

  }
}