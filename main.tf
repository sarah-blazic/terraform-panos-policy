locals {
  sec_pol_f    = jsondecode(file("sec_policy.json"))
  nat_f        = jsondecode(file("nat.json"))
  tags_y       = yamldecode(file("tags.yml"))

}
//
//module "tags_mod" {
//  source = "./modules/tags"
//  tags_file = var.tags_f
//}

resource "panos_panorama_administrative_tag" "this" {
//  for_each = {for tag in jsondecode(file("tags.json")): tag.name => tag }
  for_each = {for tag in local.tags_y: tag.name => tag }

  name          = each.key
  color         = try(each.value.color, null)
  comment       = try(each.value.comment, null)
  device_group  = try(each.value.device_group, "shared")
}

module "addr_mod" {
  source = "./modules/address"
//  addr_obj_file = var.addr_obj_f
//  addr_group_file = var.addr_group_f
}

module "services_mod" {
  source = "./modules/services"
//  services_file = var.services_f
}

//module "policy_mod" {
//  source = "./modules/policy"
//  sec_file = "sdfs"
//  nat_file = "sdfds"
//}

