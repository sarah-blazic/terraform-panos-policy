resource "panos_address_object" "this" {
//  for_each = {for obj in var.addr_obj_file: obj.name => obj}
  for_each = {for obj in jsondecode(file("addr_obj.json")): obj.name => obj}

  name           = each.key
  value          = lookup(each.value.value, each.value.type)
  type           = try(each.value.type, "ip-netmask")
  device_group   = try(each.value.device_group, "shared")
  description    = try(each.value.description, null)
  tags           = try(each.value.tags, null)
}

resource "panos_panorama_address_group" "this" {
//  for_each = {for obj in var.addr_group_file: obj.name => obj}
  for_each = {for obj in jsondecode(file("addr_group.json")): obj.name => obj}

  name              = each.key
  device_group      = try(each.value.device_group, "shared")
  static_addresses  = try(each.value.static_addresses, null)
  dynamic_match     = try(each.value.dynamic_match, null)
  description       = try(each.value.description, null)
  tags              = try(each.value.tags, null)
}