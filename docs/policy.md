
Policy as Code
---
Use JSON/YAML files to create resources on the panos panorama.

1) The JSON files must be able to validate two different github actions (one checking for duplicate object names and one making sure it validates against the provided schemas).
2) There are two modules : policy and security profiles which can create different resources on the panos panorama depending on what file you put into the module.

Requirements
---
* Terraform 0.13+

Providers
---
Name | Version
-----|------
panos | 1.8.3

Policy module
---
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

Secuirty Profile module
---
Inputs
---
Name | Description | Type | Default | Required
-----|-----|-----|-----|-----
antivirus_file | (optional) Creates antivirus security profiles. |`string`|n/a|no
file_blocking_file | (optional) Creates file-blocking security profiles. | `string` | n/a | no

* each input will create a resource based off of the JSON/YAML file given

