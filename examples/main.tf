provider "panos" {
  hostname = var.hostname
  username = var.user
  password = var.password
}

module "policy" {
  source  = "sarah-blazic/policy/panos"
  version = "0.1.3"

  #for JSON files: try(jsondecode(file("<*.json>")), {})
  #for YAML files: try(yamldecode(file("<*.yaml>")), {})
  tags       = try(jsondecode(file("./files/json/tags.json")), {})
  services   = try(jsondecode(file("./files/json/services.json")), {})
  addr_group = try(jsondecode(file("./files/json/addr_group.json")), {})
  addr_obj   = try(jsondecode(file("./files/json/addr_obj.json")), {})
  sec_policy = try(jsondecode(file("./files/json/sec_policy_demo.json")), {})
  nat_policy = try(jsondecode(file("./files/json/nat.json")), {})
}


