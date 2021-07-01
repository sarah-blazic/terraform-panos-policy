resource "panos_panorama_security_rule_group" "this" {
  depends_on = [panos_panorama_administrative_tag.this, panos_panorama_service_object.this]

  #for yaml files change jsondecode => yamldecode
  for_each = var.sec_file != "optional" ? {for item in jsondecode(file(var.sec_file)):
  "${try(item.device_group, "shared")}_${try(item.rulebase, "pre-rulebase")}_${try(item.position_keyword, "")}_${try(item.position_reference, "")}"
  => item} : tomap({})

  device_group       = try(each.value.device_group, "shared")
  rulebase           = try(each.value.rulebase, "pre-rulebase")
  position_keyword   = try(each.value.position_keyword, "")
  position_reference = try(each.value.position_reference, null)

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

      dynamic target {
        for_each = lookup(rule.value, "target", null) != null ? { for t in rule.value.target : t.serial => t } : {}

        content {
          serial    = lookup(target.value, "serial", null)
          vsys_list = lookup(target.value, "vsys_list", null)
        }
      }
      negate_target = lookup(rule.value, "negate_target", false)
    }
  }
}