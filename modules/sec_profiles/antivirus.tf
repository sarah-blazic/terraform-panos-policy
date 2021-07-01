//resource "panos_antivirus_security_profile" "this" {
//  #for yaml files change jsondecode => yamldecode
//  for_each = var.antivirus_file != "optional" ? {for virus in jsondecode(file(var.antivirus_file)): virus.name => virus } : tomap({})
//
//  name              = each.key
//  device_group      = try(each.value.device_group, "shared")
//  description       = try(each.value.description, null)
//  packet_capture    = try(each.value.packet_capture, false)
//  threat_exceptions = try(each.value.threat_exceptions, null)
//
//  dynamic "decoder" {
//    for_each = { for d in each.value.decoder : d.name => d }
//    content {
//      name                     = decoder.value.name
//      action                   = lookup(decoder.value, "action", "default")
//      wildfire_action          = lookup(decoder.value, "wildfire_action", "default")
//      machine_learning_action = try(decoder.value.machine_learning_action, null)
//    }
//  }
//
////  dynamic "application_exception" {
////    for_each = ""
////    content {
////      application = ""
////      action      = ""
////    }
////  }
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