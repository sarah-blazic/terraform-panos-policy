module "policy" {
  source = "./modules/policy"

  tags_file       = try(jsondecode(file("./files/json/tags.json")), {})
  services_file   = try(jsondecode(file("./files/json/services.json")), {})
  addr_group_file = try(jsondecode(file("./files/json/addr_group.json")), {})
  addr_obj_file   = try(jsondecode(file("./files/json/addr_obj.json")), {})
  sec_file        = try(jsondecode(file("./files/json/sec_policy.json")), {})
  nat_file        = try(jsondecode(file("./files/json/nat.json")), {})
}

module "sec_prof" {
  source = "./modules/sec_profiles"

  #for JSON files: try(jsondecode(file("<*.json>")), {})
  #for YAML files: try(yamldecode(file("<*.yaml>")), {})
  antivirus_file     = try(jsondecode(file("./files/json/antivirus.json")), {})
  file_blocking_file = try(jsondecode(file("./files/json/file_blocking.json")), {})
  wildfire_file      = try(jsondecode(file("./files/json/wildfire.json")), {})
  vulnerability_file = try(jsondecode(file("./files/json/vulnerability.json")), {})
  spyware_file       = try(jsondecode(file("./files/json/spyware.json")), {})
}


