locals {
//  target = var.nat_file!= "optional" ? {for item in jsondecode(file(var.nat_file)):
//    "${try(item.device_group, "shared")}_${try(item.rulebase, "pre-rulebase")}"
//    => item ...} : tomap({})
  target = var.nat_file!= "optional" ? flatten([for item in jsondecode(file(var.nat_file)):
  { for policy in item.rules :  "${try(item.device_group, "shared")}"
  => policy if can(policy.target) } ]) : tomap([{}])

//  target_loop = { for i in local.target.rules : "i.name" => i ...}
//  target_loop = flatten([for k, v in local.target : [for obj, val in v : {
//    rules = val.rules
//  }]])
}

#if there is a target in a nat rule
//resource "panos_panorama_nat_rule" "target" {
//  depends_on = [panos_panorama_administrative_tag.this, panos_panorama_service_object.this]
//
//  #for yaml files change jsondecode => yamldecode
//  for_each = {for i in local.target.* : "i.name" => i...}
//
////  device_group = try(each.value.device_group, "shared")
////  rulebase = try(each.value.rulebase, "pre-rulebase")
//
//  destination_addresses = ["any"]
//  destination_zone = "trust"
//  name = each.key
//  source_addresses = ["any"]
//  source_zones = ["trust"]
//}


resource "panos_panorama_nat_rule_group" "this" {
  depends_on = [panos_panorama_administrative_tag.this, panos_panorama_service_object.this]

  #for yaml files change jsondecode => yamldecode
  for_each = var.nat_file != "optional" ? {for item in jsondecode(file(var.nat_file)):
  "${try(item.device_group, "shared")}_${try(item.rulebase, "pre-rulebase")}_${try(item.position_keyword, "")}_${try(item.position_reference, "")}"
  => item} : tomap({})

  device_group = try(each.value.device_group, "shared")
  rulebase = try(each.value.rulebase, "pre-rulebase")
  position_keyword = try(each.value.position_keyword, "")
  position_reference = try(each.value.position_reference, null)


  dynamic "rule" {
    #checks if there is a target and won't create the rule if there is one
    for_each = { for policy in each.value.rules : policy.name => policy if !can(policy.target) }
//    for_each = { for policy in each.value.rules : policy.name => policy }

    content {
      name = rule.value.name
      description = lookup(rule.value, "description", null)
      tags        = lookup(rule.value,"tags", null)
      type        = lookup(rule.value, "type", "ipv4" )
      disabled    = lookup(rule.value, "disabled", false)

      #bug in the resource, but this would create the target
//      dynamic target {
//        for_each = can(rule.value.target) ? { for t in rule.value.target : t.serial => t } : {}
//
//        content {
//          serial    = lookup(target.value, "serial", null)
//          vsys_list = lookup(target.value, "vsys_list", null)
//        }
//      }

//      dynamic target {
//        for_each = !can(rule.value.target) ? {} : { for t in rule.value.target : t.serial => t }
//
//        content {
//          serial    = null
//          vsys_list = null
//        }
//      }

      negate_target = lookup(rule.value, "negate_target", false)


      original_packet {
        destination_addresses = lookup(rule.value.original_packet, "destination_addresses", ["any"] )
        destination_zone      = lookup(rule.value.original_packet, "destination_zone", "any" )
        source_addresses      = lookup(rule.value.original_packet, "source_addresses", ["any"] )
        source_zones          = lookup(rule.value.original_packet, "source_zones", ["any"])
        service               = lookup(rule.value.original_packet, "service", "any" )
      }

      translated_packet {
        destination {

          dynamic "static_translation" {
            for_each = rule.value.translated_packet.destination == "static_translation" ? [1] : []
            content{
              address = lookup(rule.value.translated_packet.static_translation, "address", null)
              port    = lookup(rule.value.translated_packet.static_translation, "port", null)
            }
          }

          dynamic "dynamic_translation" {
             for_each = rule.value.translated_packet.destination == "dynamic_translation" ? [1] : []
             content {
               address      = lookup(rule.value.translated_packet.dynamic_translation, "address", null)
               port         = lookup(rule.value.translated_packet.dynamic_translation, "port", null)
               distribution = lookup(rule.value.translated_packet.dynamic_translation, "distribution", null)
             }
          }
        }

        source {
          dynamic "dynamic_ip_and_port" {
            for_each = rule.value.translated_packet.source == "dynamic_ip_and_port" ? [1] : []
            content {

              dynamic "translated_address" {
                for_each = try(rule.value.translated_packet.translated_addresses, [] , null) != null ? [1] : []
                content {
                  translated_addresses = lookup(rule.value.translated_packet, "translated_addresses", null)
                }
              }

              dynamic "interface_address" {
                for_each = lookup(rule.value.translated_packet, "interface_address", null) != null ? [1] : []
                content {
                  interface  = lookup(rule.value.translated_packet.interface_address, "interface", null)
                  ip_address = lookup(rule.value.translated_packet.interface_address, "ip_address", null)
                }
              }
            }
          }

          dynamic "dynamic_ip" {
            for_each = rule.value.translated_packet.source == "dynamic_ip" ? [1] : []
            content {
              translated_addresses = lookup(rule.value.translated_packet, "translated_addresses", [] )

              dynamic "fallback" {
                for_each = lookup(rule.value.translated_packet, "fallback", null) != null ? [1] : []

                content {
                  dynamic "translated_address" {
                    for_each = try(rule.value.translated_packet.fallback.translated_addresses, [], null) != null ? [1] : []
                    content {
                      translated_addresses = lookup(rule.value.translated_packet.fallback, "translated_addresses", null)
                    }
                  }

                  dynamic "interface_address" {
                    for_each = lookup(rule.value.translated_packet.fallback, "interface_address", null) != null ? [1] : []
                    content {
                      interface  = lookup(rule.value.translated_packet.fallback.interface_address, "interface", null )
                      type       = lookup(rule.value.translated_packet.fallback.interface_address, "type", "ip")
                      ip_address = lookup(rule.value.translated_packet.fallback.interface_address, "ip_address", null )
                    }
                  }
                }
              }
            }
          }

          dynamic "static_ip" {
            for_each = rule.value.translated_packet.source == "static_ip" ? [1] : []
            content {
              translated_address = lookup(rule.value.translated_packet.static_ip,"translated_address", null)
              bi_directional     = lookup(rule.value.translated_packet.static_ip,"bi_directional", null)
            }
          }
        }
      }
    }
  }
}

