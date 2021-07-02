resource "panos_panorama_administrative_tag" "this" {
  #for yaml files change jsondecode => yamldecode
  for_each = var.tags_file != "optional" ? { for tag in jsondecode(file(var.tags_file)) : tag.name => tag } : {}

  name         = each.key
  color        = try(each.value.color, null)
  comment      = try(each.value.comment, null)
  device_group = try(each.value.device_group, "shared")
}