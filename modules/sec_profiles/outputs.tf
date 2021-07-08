#antivirus
output "created_antivirus_prof" {
  #for yaml files change jsondecode => yamldecode
  value = var.antivirus_file != "optional" ? { for prof in jsondecode(file(var.antivirus_file)) : prof.name => prof } : tomap({})
}


#anti-spyware
output "created_spyware_prof" {
  #for yaml files change jsondecode => yamldecode
  value = var.spyware_file != "optional" ? { for prof in jsondecode(file(var.spyware_file)) : prof.name => prof } : tomap({})
}


#file blocking
output "created_file_blocking_prof" {
  #for yaml files change jsondecode => yamldecode
  value = var.file_blocking_file != "optional" ? { for prof in jsondecode(file(var.file_blocking_file)) : prof.name => prof } : tomap({})
}


#vulnerability
output "created_vulnerability_prof" {
  #for yaml files change jsondecode => yamldecode
  value = var.vulnerability_file != "optional" ? { for prof in jsondecode(file(var.vulnerability_file)) : prof.name => prof } : tomap({})
}


#wildfire analysis
output "created_wildfire_prof" {
  #for yaml files change jsondecode => yamldecode
  value = var.wildfire_file != "optional" ? { for prof in jsondecode(file(var.wildfire_file)) : prof.name => prof } : tomap({})
}