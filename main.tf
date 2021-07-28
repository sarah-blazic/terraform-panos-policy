#versions/providers
terraform {
  required_providers {
    panos = {
      source = "PaloAltoNetworks/panos"
    }
  }
  required_version = ">= 0.13"
}



#tags
resource "panos_panorama_administrative_tag" "this" {
  for_each = var.tags != "optional" ? { for tag in var.tags : tag.name => tag } : {}

  name         = each.key
  color        = try(each.value.color, null)
  comment      = try(each.value.comment, null)
  device_group = try(each.value.device_group, "shared")
}



#address objects/groups
resource "panos_address_object" "this" {
  for_each = var.addr_obj != "optional" ? { for obj in var.addr_obj : obj.name => obj } : tomap({})

  name         = each.key
  value        = lookup(each.value.value, each.value.type)
  type         = each.value.type
  device_group = try(each.value.device_group, "shared")
  description  = try(each.value.description, null)
  tags         = try(each.value.tags, null)
}

resource "panos_panorama_address_group" "this" {
  for_each = var.addr_group != "optional" ? { for obj in var.addr_group : obj.name => obj } : tomap({})

  name             = each.key
  device_group     = try(each.value.device_group, "shared")
  static_addresses = try(each.value.static_addresses, null)
  dynamic_match    = try(each.value.dynamic_match, null)
  description      = try(each.value.description, null)
  tags             = try(each.value.tags, null)
}



#services
resource "panos_panorama_service_object" "this" {
  for_each = var.services != "optional" ? { for obj in var.services : obj.name => obj } : {}

  destination_port             = each.value.destination_port
  name                         = each.key
  protocol                     = each.value.protocol
  device_group                 = try(each.value.device_group, "shared")
  description                  = try(each.value.description, null)
  source_port                  = try(each.value.source_port, null)
  tags                         = try(each.value.tags, null)
  override_session_timeout     = try(each.value.override_session_timeout, false)
  override_timeout             = try(each.value.override_timeout, null)
  override_half_closed_timeout = try(each.value.override_half_closed_timeout, null)
  override_time_wait_timeout   = try(each.value.override_time_wait_timeout, null)
}



#Security Policy
resource "panos_panorama_security_rule_group" "this" {
  depends_on = [panos_panorama_administrative_tag.this, panos_panorama_service_object.this]

  for_each = var.sec_policy != "optional" ? { for item in var.sec_policy :
    "${try(item.device_group, "shared")}_${try(item.rulebase, "pre-rulebase")}_${try(item.position_keyword, "")}_${try(item.position_reference, "")}"
  => item } : tomap({})

  device_group       = try(each.value.device_group, "shared")
  rulebase           = try(each.value.rulebase, "pre-rulebase")
  position_keyword   = try(each.value.position_keyword, "")
  position_reference = try(each.value.position_reference, null)

  dynamic "rule" {
    for_each = { for policy in each.value.rules : policy.name => policy }
    content {
      applications                       = try(rule.value.applications, ["any"])
      categories                         = try(rule.value.categories, ["any"])
      destination_addresses              = try(rule.value.destination_addresses, ["any"])
      destination_zones                  = try(rule.value.destination_zones, ["any"])
      hip_profiles                       = try(rule.value.hip_profiles, ["any"])
      name                               = rule.value.name
      services                           = try(rule.value.services, ["application-default"])
      source_addresses                   = try(rule.value.source_addresses, ["any"])
      source_users                       = try(rule.value.source_users, ["any"])
      source_zones                       = try(rule.value.source_zones, ["any"])
      description                        = try(rule.value.description, null)
      tags                               = try(rule.value.tags, null)
      type                               = try(rule.value.type, "universal")
      negate_source                      = try(rule.value.negate_source, false)
      negate_destination                 = try(rule.value.negate_destination, false)
      action                             = try(rule.value.action, "allow")
      log_setting                        = try(rule.value.log_setting, null)
      log_start                          = try(rule.value.log_start, false)
      log_end                            = try(rule.value.log_end, true)
      disabled                           = try(rule.value.disabled, false)
      schedule                           = try(rule.value.schedule, null)
      icmp_unreachable                   = try(rule.value.icmp_unreachable, null)
      disable_server_response_inspection = try(rule.value.disable_server_response_inspection, false)
      group                              = try(rule.value.group, null)
      virus                              = try(rule.value.virus, null)
      spyware                            = try(rule.value.spyware, null)
      vulnerability                      = try(rule.value.vulnerability, null)
      url_filtering                      = try(rule.value.url_filtering, null)
      file_blocking                      = try(rule.value.file_blocking, null)
      wildfire_analysis                  = try(rule.value.wildfire_analysis, null)
      data_filtering                     = try(rule.value.data_filtering, null)

      dynamic "target" {
        for_each = try(rule.value.target, null) != null ? { for t in rule.value.target : t.serial => t } : {}

        content {
          serial    = try(target.value.serial, null)
          vsys_list = try(target.value.vsys_list, null)
        }
      }
      negate_target = try(rule.value.negate_target, false)
    }
  }
}



#Nat Policy
locals {
  #for yaml examples change jsondecode => yamldecode
  target = var.nat_policy != "optional" ? flatten([for item in var.nat_policy :
    { for policy in item.rules : "${try(item.device_group, "shared")}_${try(item.rulebase, "pre-rulebase")}"
  => policy if can(policy.target) }]) : [{}]

  target_loop = flatten([for i in local.target : [for obj, val in i : {
    device_group = split("_", obj)[0]
    rulebase     = split("_", obj)[1]
    name         = val.name
    type         = try(val.type, null)
    description  = try(val.description, null)
    tags         = try(val.tags, null)
    disabled     = try(val.disabled, false)


    #original_packet
    source_addresses      = val.original_packet.source_addresses
    source_zones          = val.original_packet.source_zones
    destination_zone      = val.original_packet.destination_zone
    destination_addresses = val.original_packet.destination_addresses
    to_interface          = try(val.original_packet.destination_interface, null)
    service               = try(val.original_packet.service, null)


    #translated_packet
    #sat
    sat_type                          = try(replace(val.translated_packet.source, "_", "-"), "none")
    sat_address_trans                 = contains(keys(val.translated_packet), "translated_addresses") ? "translated-address" : null
    sat_address_inter                 = contains(keys(val.translated_packet), "interface_address") ? "interface-address" : null
    sat_translated_addresses          = try(val.translated_packet.translated_addresses, [])
    sat_interface                     = try(val.translated_packet.interface_address.interface, null)
    sat_ip_address                    = try(val.translated_packet.interface_address.ip_address, null)
    sat_fallback_type_trans           = can(val.translated_packet.fallback) ? (contains(keys(val.translated_packet.fallback), "translated_addresses") ? "translated-address" : null) : "none"
    sat_fallback_type_inter           = can(val.translated_packet.fallback) ? (contains(keys(val.translated_packet.fallback), "interface_address") ? "interface-address" : null) : "none"
    sat_fallback_translated_addresses = try(val.translated_packet.fallback.translated_addresses, [])
    sat_fallback_interface            = try(val.translated_packet.fallback.interface_address.interface, null)
    sat_fallback_ip_type              = try(val.translated_packet.fallback.interface_address.type, null)
    sat_fallback_ip_address           = try(val.translated_packet.fallback.interface_address.ip_address, null)
    sat_static_translated_address     = try(val.translated_packet.static_ip.translated_address, null)
    sat_static_bi_directional         = try(val.translated_packet.static_ip.bi_directional, false)

    #dat
    dat_type                 = try(split("_", val.translated_packet.destination)[0], null)
    dat_address_static       = contains(keys(val.translated_packet), "static_translation") ? val.translated_packet.static_translation.address : null
    dat_address_dynamic      = contains(keys(val.translated_packet), "dynamic_translation") ? val.translated_packet.dynamic_translation.address : null
    dat_port_static          = contains(keys(val.translated_packet), "static_translation") ? val.translated_packet.static_translation.port : null
    dat_port_dynamic         = contains(keys(val.translated_packet), "dynamic_translation") ? val.translated_packet.dynamic_translation.port : null
    dat_dynamic_distribution = try(val.translated_packet.dynamic_translation.distriburtion, null)


    target        = val.target
    negate_target = try(val.negate_target, false)
  }]])

}

#if there is a target in a nat rule
resource "panos_panorama_nat_rule" "target" {
  depends_on = [panos_panorama_administrative_tag.this, panos_panorama_service_object.this]

  for_each = { for i in local.target_loop : i.name => i }

  device_group = try(each.value.device_group, "shared")
  rulebase     = try(each.value.rulebase, "pre-rulebase")

  name        = each.key
  type        = try(each.value.type, "ipv4")
  description = try(each.value.description, null)
  tags        = try(each.value.tags, null)
  disabled    = try(each.value.disabled, false)

  destination_addresses = try(each.value.destination_addresses, ["any"])
  destination_zone      = try(each.value.destination_zone, "any")
  source_addresses      = try(each.value.source_addresses, ["any"])
  source_zones          = try(each.value.source_zones, ["any"])
  service               = try(each.value.service, "any")
  to_interface          = try(each.value.to_interface, "any")


  sat_type                          = try(each.value.sat_type, "none")
  sat_address_type                  = can(each.value.sat_address_type_trans) ? each.value.sat_address_type_trans : try(each.value.sat_address_type_inter, null)
  sat_translated_addresses          = try(each.value.sat_translated_addresses, [])
  sat_interface                     = try(each.value.sat_interface, null)
  sat_ip_address                    = try(each.value.sat_ip_address, null)
  sat_fallback_type                 = can(each.value.sat_fallback_type_trans) ? each.value.sat_fallback_type_trans : try(each.value.sat_fallback_type_inter, "none")
  sat_fallback_translated_addresses = try(each.value.sat_fallback_addresses, [])
  sat_fallback_interface            = try(each.value.sat_fallback_interface, null)
  sat_fallback_ip_type              = try(each.value.sat_fallback_ip_type, null)
  sat_fallback_ip_address           = try(each.value.sat_fallback_ip_address, null)
  sat_static_translated_address     = try(each.value.sat_static_translated_address, null)
  sat_static_bi_directional         = try(each.value.sat_static_bi_directional, false)

  dat_type                 = try(each.value.dat_type, "none")
  dat_address              = can(each.value.dat_address_static) ? each.value.dat_address_static : try(each.value.dat_address_dynamic, null)
  dat_port                 = can(each.value.dat_port_static) ? each.value.dat_port_static : try(each.value.dat_port_dynamic, null)
  dat_dynamic_distribution = try(each.value.dat_dynamic_distribution, null)


  dynamic "target" {
    for_each = can(each.value.target) ? { for t in each.value.target : t.serial => t } : {}

    content {
      serial    = try(target.value.serial, null)
      vsys_list = try(target.value.vsys_list, null)
    }
  }
  negate_target = try(each.value.negate_target, false)
}


resource "panos_panorama_nat_rule_group" "this" {
  depends_on = [panos_panorama_administrative_tag.this, panos_panorama_service_object.this]

  for_each = var.nat_policy != "optional" ? { for item in var.nat_policy :
    "${try(item.device_group, "shared")}_${try(item.rulebase, "pre-rulebase")}_${try(item.position_keyword, "")}_${try(item.position_reference, "")}"
  => item } : tomap({})

  device_group       = try(each.value.device_group, "shared")
  rulebase           = try(each.value.rulebase, "pre-rulebase")
  position_keyword   = try(each.value.position_keyword, "")
  position_reference = try(each.value.position_reference, null)


  dynamic "rule" {
    #checks if there is a target and won't create the rule if there is one
    for_each = { for policy in each.value.rules : policy.name => policy if !can(policy.target) }

    content {
      name        = rule.value.name
      description = try(rule.value.description, null)
      tags        = try(rule.value.tags, null)
      type        = try(rule.value.type, "ipv4")
      disabled    = try(rule.value.disabled, false)

      #bug in the resource, but this would create the target
      //      dynamic target {
      //        for_each = can(rule.value.target) ? { for t in rule.value.target : t.serial => t } : {}
      //
      //        content {
      //          serial    = lookup(target.value, "serial", null)
      //          vsys_list = lookup(target.value, "vsys_list", null)
      //        }
      //      }

      //      negate_target = try(rule.value.negate_target, false)


      original_packet {
        destination_addresses = try(rule.value.original_packet.destination_addresses, ["any"])
        destination_zone      = try(rule.value.original_packet.destination_zone, "any")
        source_addresses      = try(rule.value.original_packet.source_addresses, ["any"])
        source_zones          = try(rule.value.original_packet.source_zones, ["any"])
        service               = try(rule.value.original_packet.service, "any")
      }

      translated_packet {
        destination {

          dynamic "static_translation" {
            for_each = rule.value.translated_packet.destination == "static_translation" ? [1] : []
            content {
              address = try(rule.value.translated_packet.static_translation.address, null)
              port    = try(rule.value.translated_packet.static_translation.port, null)
            }
          }

          dynamic "dynamic_translation" {
            for_each = rule.value.translated_packet.destination == "dynamic_translation" ? [1] : []
            content {
              address      = try(rule.value.translated_packet.dynamic_translation.address, null)
              port         = try(rule.value.translated_packet.dynamic_translation.port, null)
              distribution = try(rule.value.translated_packet.dynamic_translation.distribution, null)
            }
          }
        }

        source {
          dynamic "dynamic_ip_and_port" {
            for_each = rule.value.translated_packet.source == "dynamic_ip_and_port" ? [1] : []
            content {

              dynamic "translated_address" {
                for_each = try(rule.value.translated_packet.translated_addresses, null) != null ? [1] : []
                content {
                  translated_addresses = try(rule.value.translated_packet.translated_addresses, null)
                }
              }

              dynamic "interface_address" {
                for_each = try(rule.value.translated_packet.interface_address, null) != null ? [1] : []
                content {
                  interface  = try(rule.value.translated_packet.interface_address.interface, null)
                  ip_address = try(rule.value.translated_packet.interface_address.ip_address, null)
                }
              }
            }
          }

          dynamic "dynamic_ip" {
            for_each = rule.value.translated_packet.source == "dynamic_ip" ? [1] : []
            content {
              translated_addresses = try(rule.value.translated_packet.translated_addresses, [])

              dynamic "fallback" {
                for_each = try(rule.value.translated_packet.fallback, null) != null ? [1] : []

                content {
                  dynamic "translated_address" {
                    for_each = try(rule.value.translated_packet.fallback.translated_addresses, null) != null ? [1] : []
                    content {
                      translated_addresses = try(rule.value.translated_packet.fallback.translated_addresses, null)
                    }
                  }

                  dynamic "interface_address" {
                    for_each = try(rule.value.translated_packet.fallback.interface_address, null) != null ? [1] : []
                    content {
                      interface  = try(rule.value.translated_packet.fallback.interface_address.interface, null)
                      type       = try(rule.value.translated_packet.fallback.interface_address.type, "ip")
                      ip_address = try(rule.value.translated_packet.fallback.interface_address.ip_address, null)
                    }
                  }
                }
              }
            }
          }

          dynamic "static_ip" {
            for_each = rule.value.translated_packet.source == "static_ip" ? [1] : []
            content {
              translated_address = try(rule.value.translated_packet.static_ip.translated_address, null)
              bi_directional     = try(rule.value.translated_packet.static_ip.bi_directional, false)
            }
          }
        }
      }
    }
  }
}