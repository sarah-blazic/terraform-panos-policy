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