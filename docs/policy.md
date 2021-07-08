
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
Inputs
---
Name | Description | Type | Default | Required
-----|-----|-----|-----|-----
antivirus_file | (optional) Creates antivirus security profiles. |`string`|n/a|no
file_blocking_file | (optional) Creates file-blocking security profiles. | `string` | n/a | no
spyware_file | (optional) Creates anti-spyware security profiles. |`string`|n/a|no
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
