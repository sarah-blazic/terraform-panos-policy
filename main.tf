locals {
  sec_pol_f    = jsondecode(file("sec_policy.json"))
  nat_f        = jsondecode(file("nat.json"))
//  tags_y       = yamldecode(file("tags.yml"))
//  tags_f       = jsondecode("tags.json")

//  virus = flatten([
//    for k, v in jsondecode(file("antivirus.json")) : flatten([
//      for obj, val in v : {
//       name = try(val , null)
//
//    }
//  ])
//  ])
    virus = {for virus in jsondecode(file("antivirus.json")): virus.name => virus }
    virus_loop = { for d in local.virus : "hi" => d ...}

}

module "policy" {
  source = "./modules/policy"

  tags_file = "tags.json"
  services_file = "services.json"
  addr_group_file = "addr_group.json"
  addr_obj_file = "addr_obj.json"

//  sec_file = "sec_policy.json"
  nat_file = "nat.json"


}

module "sec_prof" {
  source = "./modules/sec_profiles"

//  antivirus_file = "antivirus.json"
}

//resource "panos_antivirus_security_profile" "main" {
//  #for yaml files change jsondecode => yamldecode
//  for_each = {for virus in jsondecode(file("antivirus.json")): virus.name => virus }
//
//  name              = each.key
//  device_group      = try(each.value.device_group, "shared")
//  description       = try(each.value.description, null)
//  packet_capture    = try(each.value.packet_capture, false)
//  threat_exceptions = try(each.value.threat_exceptions, null)
//
////  dynamic "decoder" {
////    for_each = { for d in each.value.name : d.name => d }
////    content {
////      name                     = decoder.value.name
////      action                   = lookup(decoder.value, "action", "default")
////      wildfire_action          = lookup(decoder.value, "wildfire_action", "default")
////      machine_learning_action = try(decoder.value.machine_learning_action, null)
////    }
////  }
//
//  dynamic "application_exception" {
//    for_each = { for d in each.value.application_exception : d.name => d }
//    content {
//      application = ""
//      action      = ""
//    }
//  }
////
////  dynamic "machine_learning_model" {
////    for_each = ""
////    content {
////      model = ""
////      action = ""
////    }
////  }
////
////  dynamic "machine_learning_exception" {
////    for_each = ""
////    content {
////      name = ""
////      description = ""
////      filename = ""
////    }
////  }
//
//}


