
Policy as Code
---
Use JSON/YAML files to create resources on the panos panorama.

1) The JSON files must be able to validate two different github actions (one checking for duplicate object names and one making sure it validates against the provided schemas).
2) There are two modules : policy and security profiles which can create different resources on the panos panorama depending on what file you put into the module.

Usage
---
```
module "policy" {
  source = "./modules/policy"

  #for yaml files "./files/yaml/..."
  tags_file       = "./files/json/tags.json"
  services_file   = "./files/json/services.json"
  addr_group_file = "./files/json/addr_group.json"
  addr_obj_file   = "./files/json/addr_obj.json"
  sec_file        = "./files/json/sec_policy.json"
  nat_file        = "./files/json/nat.json"
}

module "sec_prof" {
  source = "./modules/sec_profiles"

  #for yaml file "./files/yaml/..."
  antivirus_file     = "./files/json/antivirus.json"
  file_blocking_file = "./files/json/file_blocking.json"
  wildfire_file      = "./files/json/wildfire.json"
  vulnerability_file = "./files/json/vulnerability.json"
  spyware_file       = "./files/json/spyware.json"
}
```


Requirements
---
* Terraform 0.13+

Providers
---
Name | Version
-----|------
panos | 1.8.3

Modules
---
No modules.

Policy module
---
Resources
---
Name | Type
-----|-----
panos_address_object.this | resource
panos_panorama_address_group.this | resource
panos_panorama_nat_rule.target | resource
panos_panorama_nat_rule_group.this | resource
panos_panorama_security_rule_group.this | resource
panos_panorama_service_object.this | resource
panos_panorama_administrative_tag.this | resource

Inputs
---
Name | Description | Type | Default | Required
-----|-----|-----|-----|-----
tags_file | (optional) Required if tags are used in nat/security policy, services, or address objects/groups. |`string`|n/a|yes
services_file | (optional) Required if services are used in nat/security policy. | `string` | n/a | yes
addr_obj_file | (optional) Required if address objects are used in nat/security policy.|`string`|n/a|yes
addr_group_file | (optional) Required if address groups are used in nat/security.|`string`|n/a|yes
sec_file | (optional) Creates security policies.|`string`|n/a|yes
nat_file | (optional) Creates NAT policies.|`string`|n/a|yes

* each input will create a resource based off of the JSON/YAML file given

Outputs
---
Name | Description
-----|-----
created_tags | Shows the tags that were created.
created_services |Shows the services that were created.
created_addr_obj |Shows the address objects that were created.
created_addr_group |Shows the address groups that were created.
created_sec |Shows the security policies that were created.
created_nat |Shows the NAT policies that were created.


Secuirty Profile module
---
Resources
---
Name | Type
-----|-----
panos_antivirus_security_profile.this | resource
panos_file_blocking_security_profile.this | resource
panos_anti_spyware_security_profile.target | resource
panos_vulnerability_security_profile.this | resource
panos_wildfire_analysis_security_profile.this | resource

Inputs
---
Name | Description | Type | Default | Required
-----|-----|-----|-----|-----
antivirus_file | (optional) Creates antivirus security profiles. |`string`|n/a|no
file_blocking_file | (optional) Creates file-blocking security profiles. | `string` | n/a | no
vulnerability_file | (optional) Creates vulnerability security profiles. |`string`|n/a|no
wildfire_file | (optional) Creates wildfire analysis security profiles. |`string`|n/a|no

* each input will create a resource based off of the JSON/YAML file given

Outputs
---
Name | Description
-----|-----
created_antivirus_prof | Shows the antivirus security profiles that were created.
created_spyware_prof |Shows the anti-spyware security profiles that were created.
created_file_blocking_prof |Shows the file blocking security profiles that were created.
created_vulnerability_prof |Shows the vulnerability security profiles that were created.
created_wildfire_prof |Shows the wildfire analysis security profiles that were created.
