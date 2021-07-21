provider "panos" {
  hostname = "<panos_address>"
  username = "<admin_username>"
  password = "<admin_password>"
}

module "policy" {
  source  = "sarah-blazic/policy/panos"
  version = "0.1.0"

  tags_file       = try(jsondecode(file("./json/tags.json")), {})
  services_file   = try(jsondecode(file("./json/services.json")), {})
  addr_group_file = try(jsondecode(file("./json/addr_group.json")), {})
  addr_obj_file   = try(jsondecode(file("./json/addr_obj.json")), {})
  sec_file        = try(jsondecode(file("./json/sec_policy.json")), {})
  nat_file        = try(jsondecode(file("./json/nat.json")), {})
}


