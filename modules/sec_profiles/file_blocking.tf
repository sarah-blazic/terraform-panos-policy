resource "panos_file_blocking_security_profile" "this" {
  #for yaml files change jsondecode => yamldecode
  for_each = var.file_blocking_file != "optional" ? { for file in jsondecode(file(var.file_blocking_file)) : file.name => file } : tomap({})

  name              = each.key
  device_group      = try(each.value.device_group, "shared")
  description       = try(each.value.description, null)

  dynamic "rule" {
    for_each = lookup(each.value, "rule", null) != null ? { for rules in each.value.rule : rules.name => rules } : tomap({})
    content {
      name         = rule.value.name
      applications = lookup(rule.value, "applications", ["any"] )
      file_types   = lookup(rule.value, "file_types", ["any"] )
      direction    = lookup(rule.value, "direction", "both" )
      action       = lookup(rule.value, "action", "alert" )
    }
  }
}