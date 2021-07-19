resource "panos_address_object" "this" {
  for_each = var.addr_obj_file != "optional" ? { for obj in var.addr_obj_file : obj.name => obj } : tomap({})

  name         = each.key
  value        = lookup(each.value.value, each.value.type)
  type         = each.value.type
  device_group = try(each.value.device_group, "shared")
  description  = try(each.value.description, null)
  tags         = try(each.value.tags, null)
}

resource "panos_panorama_address_group" "this" {
  for_each = var.addr_group_file != "optional" ? { for obj in var.addr_group_file : obj.name => obj } : tomap({})

  name             = each.key
  device_group     = try(each.value.device_group, "shared")
  static_addresses = try(each.value.static_addresses, null)
  dynamic_match    = try(each.value.dynamic_match, null)
  description      = try(each.value.description, null)
  tags             = try(each.value.tags, null)
}