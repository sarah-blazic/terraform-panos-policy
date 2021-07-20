resource "panos_anti_spyware_security_profile" "this" {

  for_each = var.spyware_file != "optional" ? { for file in var.spyware_file : file.name => file... } : tomap({})


  name                  = each.key
  device_group          = try(each.value.device_group, "shared")
  description           = try(each.value.description, null)
  sinkhole_ipv4_address = try(each.value.sinkhole_ipv4_address, null)
  sinkhole_ipv6_address = try(each.value.sinkhole_ipv6_address, null)
  threat_exceptions     = try(each.value.threat_exceptions, null)

  dynamic "botnet_list" {
    for_each = try(each.value.botnet_list, null) != null ? { for botnet in each.value.botnet_list : botnet.name => botnet } : {}
    content {
      name           = botnet_list.value.name
      action         = try(botnet_list.value.action, "default")
      packet_capture = try(botnet_list.value.packet_capture, "disable")
    }
  }

  dynamic "dns_category" {
    for_each = try(each.value.dns_category, null) != null ? { for cat in each.value.dns_category : cat.name => cat } : {}
    content {
      name           = dns_category.value.name
      action         = try(dns_category.value.action, "default")
      log_level      = try(dns_category.value.log_level, "default")
      packet_capture = try(dns_category.value.packet_capture, "disable")
    }
  }

  dynamic "white_list" {
    for_each = try(each.value.white_list, null) != null ? { for list in each.value.white_list : list.name => list } : {}
    content {
      name        = white_list.value.name
      description = try(white_list.value.description, null)
    }
  }

  dynamic "rule" {
    for_each = try(each.value.rule, null) != null ? { for rules in each.value.rule : rules.name => rules } : tomap({})
    content {
      name              = rule.value.name
      threat_name       = try(rule.value.threat_name, "any")
      severities        = try(rule.value.severities, ["any"])
      category          = try(rule.value.category, "any")
      action            = try(rule.value.action, "default")
      block_ip_track_by = try(rule.value.action, null) == "block-ip" ? try(rule.value.block_ip_track_by, null) : null
      block_ip_duration = try(rule.value.action, null) == "block-ip" ? try(rule.value.block_ip_duration) : null
      packet_capture    = try(rule.value.packet_capture, "disable")
    }
  }

  dynamic "exception" {
    for_each = try(each.value.exception, null) != null ? { for ex in each.value.exception : ex.name => ex } : tomap({})
    content {
      name              = exception.value.name
      action            = try(exception.value.action, "default")
      block_ip_track_by = try(exception.value.action, null) == "block-ip" ? try(exception.value.block_ip_track_by, null) : null
      block_ip_duration = try(exception.value.action, null) == "block-ip" ? try(exception.value.block_ip_duration, null) : null
      packet_capture    = try(exception.value.packet_capture, "disable")
      exempt_ips        = try(exception.value.exempt_ips, null)
    }
  }
}