module "policy" {
  source = "./modules/policy"

  #for yaml files "./files/yaml/..."
  tags_file       = "./files/json/tags.json"
  services_file   = "./files/json/services.json"
  addr_group_file = "./files/json/addr_group.json"
  addr_obj_file   = "./files/json/addr_obj.json"
  sec_file        = "./files/json/sec_policy.json"
  //  nat_file        = "./files/json/nat.json"
}

module "sec_prof" {
  source = "./modules/sec_profiles"

  #for yaml file "./files/yaml/..."
  antivirus_file     = "./files/json/antivirus.json"
  file_blocking_file = "./files/json/file_blocking.json"
  wildfire_file      = "./files/json/wildfire.json"
}


