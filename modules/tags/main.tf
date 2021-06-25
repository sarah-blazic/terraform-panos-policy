resource "panos_panorama_administrative_tag" "this" {
  for_each = {for tag in jsondecode(file(var.tags_file)): tag.name => tag }

  name          = each.key
  color         = try(each.value.color, null)
  comment       = try(each.value.comment, null)
  device_group  = try(each.value.device_group, "shared")
}