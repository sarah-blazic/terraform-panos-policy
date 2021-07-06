resource "panos_anti_spyware_security_profile" "this" {
  #for yaml files change jsondecode => yamldecode
  for_each = var.spyware_file != "optional" ? { for file in jsondecode(file(var.spyware_file)) : file.name => file } : tomap({})

  name                  = each.key
  device_group          = try(each.value.device_group, "shared")
  description           = try(each.value.description, null)
  sinkhole_ipv4_address = try(each.value.sinkhole_ipv4_address, null)
  sinkhole_ipv6_address = try(each.value.sinkhole_ipv6_address, null)
  threat_exceptions     = try(each.value.threat_exceptions, null)

  dynamic "botnet_list" {
    for_each = lookup(each.value, "botnet_list", null) != null ? { for botnet in each.value.botnet_list : botnet.name => botnet } : tomap({})
    content {
      name           = botnet_list.value.name
      action         = lookup(botnet_list.value, "action", "default")
      packet_capture = lookup(botnet_list.value, "packet_capture", "disable")
    }
  }

  dynamic "dns_category" {
    for_each = lookup(each.value, "dns_category", null) != null ? { for cat in each.value.dns_category : cat.name => cat } : tomap({})
    content {
      name           = dns_category.value.name
      action         = lookup(dns_category.value, "action", "default" )
      log_level      = lookup(dns_category.value, "log_level", "default" )
      packet_capture = lookup(dns_category.value, "packet_capture", "disable" )
    }
  }

//  dynamic "white_list" {
//    for_each = ""
//    content {
//      name = ""
//      description = ""
//    }
//  }

  dynamic "rule" {
    for_each = lookup(each.value, "rule", null) != null ? { for rules in each.value.rule : rules.name => rules } : tomap({})
    content {
      name              = rule.value.name
      threat_name       = lookup(rule.value, "threat_name", "any")
      severities        = lookup(rule.value, "severities", ["any"])
      category          = lookup(rule.value, "category", "any")
      action            = lookup(rule.value, "action", "default")
      block_ip_track_by = try(rule.value.action, null) == "block-ip" ? lookup(rule.value, "block_ip_track_by") : null
      block_ip_duration = try(rule.value.action, null) == "block-ip" ? lookup(rule.value, "block_ip_duration") : null
      packet_capture    = lookup(rule.value, "packet_capture", "disable")
    }
  }

  dynamic "exception" {
    for_each = lookup(each.value, "exception", null) != null ? { for ex in each.value.exception : ex.name => ex } : tomap({})
    content {
      name              = exception.value.name
      action            = lookup(exception.value, "action", "default")
      block_ip_track_by = try(exception.value.action, null) == "block-ip" ? lookup(exception.value, "block_ip_track_by") : null
      block_ip_duration = try(exception.value.action, null) == "block-ip" ? lookup(exception.value, "block_ip_duration") : null
      packet_capture    = lookup(exception.value, "packet_capture", "disable")
      exempt_ips        = lookup(exception.value, "exempt_ips", null)
    }
  }
}